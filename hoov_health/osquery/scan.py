import subprocess
import json

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
with open("json/all_scans.json", "w") as outfile:
    json.dump(results, outfile, indent=4)

print(f"Scan results have been exported to json/all_scans.json")
