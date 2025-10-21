#!/bin/bash
# Comprehensive cost tracking and logging

DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
COST_DIR="cost-history"

# Create cost history directory
mkdir -p $COST_DIR

echo "📊 CAPTURING COST DATA FOR $DATE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get detailed cost breakdown
aws ce get-cost-and-usage \
  --time-period Start=$DATE,End=$(date -v+1d +%Y-%m-%d 2>/dev/null || date -d tomorrow +%Y-%m-%d) \
  --granularity DAILY \
  --metrics "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE \
  --query 'ResultsByTime[0].Groups[?Metrics.UnblendedCost.Amount!=`0`].{Service:Keys[0],Cost:Metrics.UnblendedCost.Amount}' \
  --output json > "$COST_DIR/detailed-costs-$DATE.json"

# Get total cost
TOTAL_COST=$(aws ce get-cost-and-usage \
  --time-period Start=$DATE,End=$(date -v+1d +%Y-%m-%d 2>/dev/null || date -d tomorrow +%Y-%m-%d) \
  --granularity DAILY \
  --metrics "UnblendedCost" \
  --query 'ResultsByTime[0].Total.UnblendedCost.Amount' \
  --output text)

# Create CSV log entry
echo "$DATE,$TOTAL_COST" >> "$COST_DIR/daily-costs.csv"

# Create detailed log
cat > "$COST_DIR/session-log-$DATE.txt" << LOGEOF
Landing Zone POC - Cost Session Log
Date: $TIMESTAMP
Total Cost: \$$TOTAL_COST

Service Breakdown:
LOGEOF

aws ce get-cost-and-usage \
  --time-period Start=$DATE,End=$(date -v+1d +%Y-%m-%d 2>/dev/null || date -d tomorrow +%Y-%m-%d) \
  --granularity DAILY \
  --metrics "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE \
  --query 'ResultsByTime[0].Groups[?Metrics.UnblendedCost.Amount!=`0`].{Service:Keys[0],Cost:Metrics.UnblendedCost.Amount}' \
  --output table >> "$COST_DIR/session-log-$DATE.txt"

# Add infrastructure inventory
echo "" >> "$COST_DIR/session-log-$DATE.txt"
echo "Infrastructure Deployed:" >> "$COST_DIR/session-log-$DATE.txt"
terraform state list 2>/dev/null >> "$COST_DIR/session-log-$DATE.txt" || echo "No Terraform state found" >> "$COST_DIR/session-log-$DATE.txt"

echo "✅ Cost data saved to:"
echo "   📋 $COST_DIR/session-log-$DATE.txt"
echo "   📊 $COST_DIR/detailed-costs-$DATE.json"
echo "   📈 $COST_DIR/daily-costs.csv"
