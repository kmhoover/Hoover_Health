import json
import csv

# Load malicious ports from CSV
def load_malicious_ports(csv_file):
    malicious_ports = {}
    with open(csv_file, "r") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            port = row["Port"]
            malicious_ports[port] = {
                "Protocol": row["Protocol"],
                "Known Malicious Use": row["Known Malicious Use"]
            }
    return malicious_ports

# Parse results and flag potential issues with process information
def parse_and_flag(results, malicious_ports):
    flags = []
    # Create a map of pids to process details from running_processes
    process_map = {entry["pid"]: entry for entry in results["running_processes"]}
    
    # Check each entry in listening_ports against malicious ports
    for entry in results["listening_ports"]:
        port = entry["port"]
        pid = entry["pid"]
        
        # Check if the port is flagged as malicious
        if port in malicious_ports:
            # Get process details if available
            process_info = process_map.get(pid, {})
            process_name = process_info.get("name", "Unknown")
            process_path = process_info.get("path", "Unknown")
            
            # Add the flagged issue with process details
            flags.append({
                "Port": port,
                "Protocol": malicious_ports[port]["Protocol"],
                "Known Malicious Use": malicious_ports[port]["Known Malicious Use"],
                "Process Name": process_name,
                "PID": pid,
                "Path": process_path if process_path else "N/A"
            })
    return flags

# Load the scan results from JSON
with open("json/all_scans.json", "r") as infile:
    loaded_results = json.load(infile)

# Load the list of malicious ports from CSV
malicious_ports = load_malicious_ports("csv/port.csv")

# Flag issues based on loaded results and malicious ports
flagged_issues = parse_and_flag(loaded_results, malicious_ports)

# Export flagged issues to CSV
csv_file_path = "csv/flagged_issues.csv"
with open(csv_file_path, "w", newline="") as csvfile:
    fieldnames = ["Port", "Protocol", "Known Malicious Use", "Process Name", "PID", "Path"]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    
    writer.writeheader()
    for issue in flagged_issues:
        writer.writerow(issue)

print(f"Flagged issues have been exported to {csv_file_path}")
