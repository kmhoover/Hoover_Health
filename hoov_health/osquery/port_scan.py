import json
import csv
from scan import run_osquery_command


# OSQuery command
commands = {
    "listening_ports": "SELECT pid, port, protocol FROM listening_ports;",
}

# Run the command and save results
results = {}
for key, query in commands.items():
    results[key] = run_osquery_command(query)

# Save the result to a JSON file
with open("json/port_scan.json", "w") as outfile:
    json.dump(results, outfile, indent=4)

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

# Parse results to flag potential issues
def parse_and_flag(results, malicious_ports):
    flags = []
    for entry in results["listening_ports"]:
        port = entry["port"]
        if port in malicious_ports:
            flags.append({
                "Port": port,
                "Protocol": malicious_ports[port]["Protocol"],
                "Known Malicious Use": malicious_ports[port]["Known Malicious Use"]
            })
    return flags

with open("json/port_scan.json", "r") as infile:
    loaded_results = json.load(infile)

malicious_ports = load_malicious_ports("csv/port.csv")

flagged_issues = parse_and_flag(loaded_results, malicious_ports)

print("Open Ports:")
for issue in flagged_issues:
    print(f"Port: {issue['Port']}, Protocol: {issue['Protocol']}, Known Malicious Use: {issue['Known Malicious Use']}")
