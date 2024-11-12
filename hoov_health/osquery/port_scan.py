import json
import subprocess


# OSQuery command
commands = {
    "listening_ports": "SELECT pid, port, protocol FROM listening_ports;",
    "running_processes": "SELECT name, pid, path FROM processes;"
}

# Run command and convert to json
def run_osquery_command(query):
    try:
        output = subprocess.check_output(['osqueryi', '--json', query])
        return json.loads(output)
    except subprocess.CalledProcessError as e:
        print(f"Error running query: {query}")
        return []

# Run the command and save results
results = {}
for key, query in commands.items():
    results[key] = run_osquery_command(query)

# Save the result to a JSON file
with open("port_scan.json", "w") as outfile:
    json.dump(results, outfile, indent=4)

# Parse results to flag potential issues
def parse_and_flag(results):
    flags = []
    # Check for SSH (port 22) as an example
    if any(port["port"] == "135" for port in results["results"]):
        flags.append("SSH port 22 is open; review if required.")
    return flags

# Load results and flag issues
with open("results.json", "r") as infile:
    loaded_results = json.load(infile)
    flagged_issues = parse_and_flag(loaded_results)

print("Potential security flags:", flagged_issues)
