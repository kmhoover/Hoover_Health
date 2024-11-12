import subprocess
import json
# Run command and convert to json
def run_osquery_command(query):
    try:
        output = subprocess.check_output(['osqueryi', '--json', query])
        return json.loads(output)
    except subprocess.CalledProcessError as e:
        print(f"Error running query: {query}")
        return []