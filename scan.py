import os
import subprocess
import json
import argparse

def run_scripts(scripts):
    for script in scripts:
        result = subprocess.run(script, shell=True)
        if result.returncode != 0:
            print(f"Error running script: {script}")
            return result.returncode
    return 0

def read_json_file(file_path):
    try:
        with open(file_path, 'r') as file:
            return json.load(file)
    except Exception as e:
        print(f"Error reading JSON file {file_path}: {e}")
        return None

def main(selected_scripts):
    script_map = {
        "bluetooth": "queries/bluetooth",
        "os_version": "queries/os_version",
        "port_info": "queries/port_info",
        "running_apps": "queries/running_apps",
        "system_info": "queries/system_info",
        "wifi_info": "queries/wifi_info"
    }

    json_file_map = {
        "bluetooth": "json_files/bluetooth.json",
        "os_version": "json_files/os_version.json",
        "port_info": "json_files/port_info.json",
        "running_apps": "json_files/running_apps.json",
        "system_info": "json_files/system_info.json",
        "wifi_info": "json_files/wifi_info.json"
    }

    scripts = [script_map[key] for key in selected_scripts]
    json_files = [json_file_map[key] for key in selected_scripts]
    combined_results = {}

    # Run each script
    if run_scripts(scripts) != 0:
        return -1

    # Read and combine JSON files
    for json_file in json_files:
        json_data = read_json_file(json_file)
        if json_data is None:
            continue

        # Extract the file name without directory and extension
        file_name = os.path.splitext(os.path.basename(json_file))[0]

        # Add the content of the current JSON file under its filename key
        combined_results[file_name] = json_data

    # Write combined results to a single JSON file
    combined_json_file_path = "json_files/combined_results.json"
    try:
        with open(combined_json_file_path, 'w') as combined_file:
            json.dump(combined_results, combined_file, indent=4)
        print(f"Combined data successfully written to {combined_json_file_path}")
    except Exception as e:
        print(f"Error writing combined JSON data to file: {e}")
        return -1

    return 0

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run specific system info queries and combine results.")
    parser.add_argument("-b", "--bluetooth", action="store_true", help="Run Bluetooth query")
    parser.add_argument("-os", "--os_version", action="store_true", help="Run OS version query")
    parser.add_argument("-p", "--port_info", action="store_true", help="Run port info query")
    parser.add_argument("-r", "--running_apps", action="store_true", help="Run running apps query")
    parser.add_argument("-s", "--system_info", action="store_true", help="Run system info query")
    parser.add_argument("-w", "--wifi", action="store_true", help="Run WiFi info query")
    
    args = parser.parse_args()
    
    # Determine which scripts to run based on provided flags
    selected_scripts = []
    if args.bluetooth:
        selected_scripts.append("bluetooth")
    if args.os_version:
        selected_scripts.append("os_version")
    if args.port_info:
        selected_scripts.append("port_info")
    if args.running_apps:
        selected_scripts.append("running_apps")
    if args.system_info:
        selected_scripts.append("system_info")
    if args.wifi:
        selected_scripts.append("wifi_info")
    
    # If no flags are provided, run all scripts
    if not selected_scripts:
        selected_scripts = ["bluetooth", "os_version", "port_info", "running_apps", "system_info", "wifi_info"]
    
    main(selected_scripts)
