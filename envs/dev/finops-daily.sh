#!/bin/bash
# Daily FinOps Report for AWS Landing Zone POC

echo "💰 DAILY FINOPS REPORT - $(date +%Y-%m-%d)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get yesterday's costs
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d yesterday +%Y-%m-%d)
TODAY=$(date +%Y-%m-%d)

echo "📊 COSTS BY SERVICE (${YESTERDAY} to ${TODAY}):"
aws ce get-cost-and-usage \
  --time-period Start=${YESTERDAY},End=${TODAY} \
  --granularity DAILY \
  --metrics "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE \
  --query 'ResultsByTime[0].Groups[?Metrics.UnblendedCost.Amount!=`0`].{Service:Keys[0],Cost:Metrics.UnblendedCost.Amount}' \
  --output table

# Get total cost
TOTAL_COST=$(aws ce get-cost-and-usage \
  --time-period Start=${YESTERDAY},End=${TODAY} \
  --granularity DAILY \
  --metrics "UnblendedCost" \
  --query 'ResultsByTime[0].Total.UnblendedCost.Amount' \
  --output text)

echo ""
echo "💵 TOTAL COST: \$${TOTAL_COST} USD"

# Estimate monthly cost if left running
MONTHLY_ESTIMATE=$(echo "${TOTAL_COST} * 30" | bc -l 2>/dev/null || python3 -c "print(f'{float('${TOTAL_COST}') * 30:.2f}')")
echo "📈 MONTHLY ESTIMATE (if left running): ~\$${MONTHLY_ESTIMATE} USD"

echo ""
echo "�� FINOPS ACTIONS:"
echo "├─ ✅ Run daily cost report"
echo "├─ 🚨 DESTROY infrastructure when done: make -f ../../Makefile destroy"
echo "├─ 📋 Log costs in POC documentation"
echo "└─ 🔄 Rebuild tomorrow: make -f ../../Makefile apply"

echo ""
echo "🏷️ DEPLOYED RESOURCES:"
terraform state list | wc -l | xargs echo "Total resources:"

echo ""
echo "⚡ QUICK ACTIONS:"
echo "• Destroy now: make -f ../../Makefile destroy"
echo "• View Cost Explorer: https://console.aws.amazon.com/billing/home#/costexplorer"
