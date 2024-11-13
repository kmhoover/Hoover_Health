import json
from scan import run_osquery_command

# OSQuery command
commands = {
    "running_processes": "SELECT name, pid, path FROM processes;"
}

# Run the command and save results
results = {}
for key, query in commands.items():
    results[key] = run_osquery_command(query)

# Save the result to a JSON file
with open("json/process_scan.json", "w") as outfile:
    json.dump(results, outfile, indent=4)
