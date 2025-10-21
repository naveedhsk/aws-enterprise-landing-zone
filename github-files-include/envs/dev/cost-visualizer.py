#!/usr/bin/env python3
"""
Simple cost visualization for Landing Zone POC
"""
import json
import csv
import os
from datetime import datetime

def read_daily_costs():
    """Read daily costs from CSV"""
    costs = []
    csv_file = "cost-history/daily-costs.csv"
    
    if os.path.exists(csv_file):
        with open(csv_file, 'r') as f:
            reader = csv.reader(f)
            for row in reader:
                if len(row) == 2:
                    date, cost = row
                    costs.append((date, float(cost)))
    return costs

def create_simple_graph(costs):
    """Create a simple ASCII graph"""
    if not costs:
        return "No cost data available"
    
    # Sort by date
    costs.sort(key=lambda x: x[0])
    
    graph = "\n📈 COST TREND GRAPH\n"
    graph += "━" * 50 + "\n"
    
    max_cost = max(cost for _, cost in costs) if costs else 0
    
    for date, cost in costs:
        # Create simple bar graph
        bar_length = int((cost / max_cost) * 30) if max_cost > 0 else 0
        bar = "█" * bar_length
        graph += f"{date}: ${cost:6.3f} |{bar}\n"
    
    total_cost = sum(cost for _, cost in costs)
    avg_cost = total_cost / len(costs) if costs else 0
    
    graph += "━" * 50 + "\n"
    graph += f"Total Cost: ${total_cost:.3f}\n"
    graph += f"Average Daily: ${avg_cost:.3f}\n"
    graph += f"Days Tracked: {len(costs)}\n"
    
    return graph

def read_latest_service_breakdown():
    """Read latest service cost breakdown"""
    latest_date = datetime.now().strftime("%Y-%m-%d")
    json_file = f"cost-history/detailed-costs-{latest_date}.json"
    
    if os.path.exists(json_file):
        with open(json_file, 'r') as f:
            return json.load(f)
    return []

def create_service_breakdown():
    """Create service cost breakdown"""
    services = read_latest_service_breakdown()
    
    if not services:
        return "No service breakdown available"
    
    breakdown = "\n💰 SERVICE COST BREAKDOWN\n"
    breakdown += "━" * 50 + "\n"
    
    # Sort by cost (descending)
    services.sort(key=lambda x: float(x['Cost']), reverse=True)
    
    total = sum(float(service['Cost']) for service in services)
    
    for service in services:
        cost = float(service['Cost'])
        percentage = (cost / total * 100) if total > 0 else 0
        service_name = service['Service'][:25]  # Truncate long names
        breakdown += f"{service_name:25} ${cost:6.3f} ({percentage:4.1f}%)\n"
    
    breakdown += "━" * 50 + "\n"
    breakdown += f"{'TOTAL':25} ${total:6.3f} (100.0%)\n"
    
    return breakdown

if __name__ == "__main__":
    print("🎯 LANDING ZONE POC - COST ANALYSIS")
    print("=" * 60)
    
    # Read and display costs
    costs = read_daily_costs()
    print(create_simple_graph(costs))
    print(create_service_breakdown())
    
    # Show file locations
    print("\n📁 COST DATA FILES:")
    print("━" * 30)
    for file in os.listdir("cost-history"):
        if file.endswith(('.txt', '.json', '.csv')):
            print(f"   📄 cost-history/{file}")
