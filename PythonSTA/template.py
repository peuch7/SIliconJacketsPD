import os
import re

current_dir = os.getcwd()
file_list = os.listdir(current_dir)
print("Files in directory:", file_list)

# Open and parse the timing report
report_file = "full_paths.max.rpt"

paths = []
current_path = {}

threshold_time = 0.010  # 10 ps

with open(report_file, 'r') as f:
    lines = f.readlines()

# Parse the report
for i, line in enumerate(lines):
    # Look for path boundaries
    if "Startpoint:" in line:
        if current_path:  # Save previous path
            paths.append(current_path)
        current_path = {
            'startpoint': line.split(':')[1].strip(),
            'gates': 0,
            'slack': None,
            'arrival_time': None,
            'required_time': None,
            'path_details': []
        }
    
    # Count gates (instance names like U104, U616, etc.)
    # Match patterns like "   U###/..." which indicate gate traversals
    if re.match(r'^\s+U\d+/', line) and current_path:
        current_path['gates'] += 1
    
    # Extract arrival time
    if "data arrival time" in line and "slack" not in line:
        match = re.search(r'(\d+\.\d+)\s*$', line)
        if match:
            current_path['arrival_time'] = float(match.group(1))
    
    # Extract required time
    if "data required time" in line:
        match = re.search(r'(\d+\.\d+)\s*$', line)
        if match:
            current_path['required_time'] = float(match.group(1))
    
    # Extract slack
    if "slack" in line and ("MET" in line or "VIOLATED" in line):
        match = re.search(r'(-?\d+\.\d+)', line)
        if match:
            slack_value = float(match.group(1))
            current_path['slack'] = slack_value
            current_path['endpoint'] = lines[i-10:i]  # Store context

# Add last path
if current_path:
    paths.append(current_path)

print(f"\nTotal paths analyzed: {len(paths)}\n")

# ============ ANALYSIS ============

# 1. Count violated paths (negative slack)
violated_paths = [p for p in paths if p['slack'] is not None and p['slack'] < 0]
print(f"1. VIOLATED PATHS (negative slack): {len(violated_paths)}")
if violated_paths:
    for path in violated_paths[:5]:  # Show first 5
        print(f"   - Slack: {path['slack']:.4f} ns")

# 2. Average depth on paths with least positive slack
positive_slack_paths = [p for p in paths if p['slack'] is not None and p['slack'] >= 0]
positive_slack_paths.sort(key=lambda x: x['slack'])

print(f"\n2. AVERAGE DEPTH ON LEAST POSITIVE SLACK PATHS:")
if positive_slack_paths:
    # Get paths with minimum slack margin (tightest paths)
    min_slack = positive_slack_paths[0]['slack']
    critical_paths = [p for p in positive_slack_paths if p['slack'] <= min_slack + threshold_time]  # Within 50ps
    
    if critical_paths:
        avg_depth = sum(p['gates'] for p in critical_paths) / len(critical_paths)
        print(f"   - Minimum slack: {min_slack:.4f} ns")
        print(f"   - Critical paths (within {threshold_time * 1000:.0f}ps): {len(critical_paths)}")
        print(f"   - Average gate depth: {avg_depth:.2f} gates")
        print(f"   - Gates range: {min(p['gates'] for p in critical_paths)} to {max(p['gates'] for p in critical_paths)}")

# 3. Frequency analysis
print(f"\n3. FREQUENCY ANALYSIS:")
# From the report, clock period is 1.0 ns
clock_period = 1.0  # ns
frequency = 1000 / clock_period  # MHz
print(f"   - Clock period: {clock_period:.2f} ns")
print(f"   - Current frequency: {frequency:.0f} MHz (1.0 GHz)")

# Check if we can push frequency
if positive_slack_paths:
    max_slack = max(p['slack'] for p in positive_slack_paths)
    min_slack = min(p['slack'] for p in positive_slack_paths)
    print(f"   - Slack range: {min_slack:.4f} to {max_slack:.4f} ns")
    print(f"   - Tightest path slack: {min_slack:.4f} ns")
    
    # Theoretical max frequency with tightest path
    if min_slack > 0:
        new_period = clock_period - min_slack
        new_frequency = 1000 / new_period
        print(f"   - Could potentially push to: ~{new_frequency:.0f} MHz ({new_period:.4f} ns period)")
        print(f"   - Frequency headroom: {((new_frequency/frequency - 1) * 100):.1f}% potential increase")
    else:
        print(f"   - Design is at margin with ~0 slack - NO frequency headroom available")
        print(f"   - Would need to optimize critical paths before increasing frequency")

# 4. Issues with signoff report
print(f"\n4. ISSUES WITH SIGNOFF REPORT (after routing):")
print(f"   - Back-annotated delays are present (see report header)")
print(f"   - Using RealRC (Cmin) extraction mode - may not reflect actual worst-case")
print(f"   - Very tight timing margins (tightest slack: {min_slack:.4f} ns = {min_slack*1000:.2f} ps)")
print(f"   - Multiple paths very close to the margin, limiting design robustness")
print(f"   - Small slack leaves little room for temperature/voltage variations")

# 5. Resolution and recommendations
print(f"\n5. RESOLUTION AND OPTIMIZATION:")
print(f"   - Reduce clock period carefully given tight margins")
print(f"   - For 10% frequency increase: period = {clock_period * 0.909:.4f} ns (1.1 GHz)")
print(f"   - Recommended actions:")
print(f"     * Perform buffer insertion on critical paths")
print(f"     * Optimize gate sizing on high-depth paths")
print(f"     * Consider placement optimization near critical endpoints")
print(f"     * Verify sign-off with worst-case corner (not just FF)")
print(f"     * Add clock skew analysis (not just ideal clock network)")

print(f"\n" + "="*60)
print(f"SUMMARY: Design is timing-critical with very little slack margin.")
print(f"Current frequency: 1.0 GHz, potential for ~10% improvement with optimization")
print(f"="*60)

print(f"\n\nWorst negative slack: {min(p['slack'] for p in violated_paths):.4f} ns")