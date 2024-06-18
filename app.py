
#source ~/Desktop/hoover_health/.venv/bin/activate
from flask import Flask, render_template, jsonify, request, redirect, url_for
import json

app = Flask(__name__)

def load_json_data(file_name):
    with open(file_name, 'r') as file:
        data = json.load(file)
    return data

def save_json_data(file_name, data):
    with open(file_name, 'w') as file:
        json.dump(data, file, indent=4)

def load_expected_devices(file_path='json_standards/bluetooth_standard.json'):
    with open(file_path, 'r') as file:
        data = json.load(file)
    return data['expected_devices']

def get_threshold_value(thresholds, key):
    return thresholds['threshold'].get(key)

def determine_color(value, threshold):
    return 'green' if value >= threshold else 'red'

@app.route('/')
def index():
    scan_types = ['wifi_info', 'bluetooth', 'os_version', 'port_info', 'running_apps', 'system_info']
    data = load_json_data('json_files/combined_results.json')
    bluetooth_standard = load_json_data('json_standards/bluetooth_standard.json')
    wifi_thresholds = load_json_data('json_standards/wifi_thresholds.json')  # Load Wi-Fi thresholds
    hostname = data['system_info']['hostname']

    # Prepare expected devices set for easier lookup
    expected_devices = {name: address for device in bluetooth_standard['expected_devices'] for name, address in device.items()}

    # Prepare Bluetooth data for rendering
    for device in data['bluetooth']['device_connected']:
        for device_name, device_info in device.items():
            device_address = device_info['device_address']
            if device_name in expected_devices and device_address == expected_devices[device_name]:
                device_info['is_unexpected'] = False
            else:
                device_info['is_unexpected'] = True

     # Determine color for Wi-Fi values
    wifi_colors = {}
    desired_keys = ["RSSI", "Noise_Level", "Transmit_Rate"]  # Keys to display
    for key in desired_keys:
        if key in data['wifi_info']:  # Check if key exists in wifi_info
            threshold = get_threshold_value(wifi_thresholds, key)
            if threshold is not None:
                wifi_colors[key] = determine_color(data['wifi_info'][key], threshold)
    
    return render_template('index.html', scan_types=scan_types, data=data, hostname=hostname, wifi_colors=wifi_colors)

@app.route('/scan/<scan_type>')
def scan_result(scan_type):
    file_path = f'json_files/{scan_type}.json'
    data = load_json_data(file_path)

    return render_template('scan_result.html', scan_type=scan_type.replace('_', ' ').title(), data=data)

@app.route('/add_bluetooth_device', methods=['POST'])
def add_bluetooth_device():
    device_name = request.form['device_name']
    device_address = request.form['device_address']
    new_device = {device_name: device_address}

    bluetooth_standard = load_json_data('json_standards/bluetooth_standard.json')
    bluetooth_standard['expected_devices'].append(new_device)
    save_json_data('json_standards/bluetooth_standard.json', bluetooth_standard)

    return redirect(url_for('index'))

@app.route('/expected_devices', methods=['GET', 'POST'])
def expected_devices():
    bluetooth_standard = load_json_data('json_standards/bluetooth_standard.json')
    if request.method == 'POST':
        device_name = request.form.get('device_name')
        bluetooth_standard['expected_devices'] = [d for d in bluetooth_standard['expected_devices'] if list(d.keys())[0] != device_name]
        save_json_data('json_standards/bluetooth_standard.json', bluetooth_standard)
        return redirect(url_for('expected_devices'))
    return render_template('expected_bluetooth.html', data=bluetooth_standard)

@app.route('/wifi_thresholds', methods=['GET', 'POST'])
def wifi_thresholds():
    wifi_thresholds = load_json_data('json_standards/wifi_thresholds.json')  # Load Wi-Fi thresholds

    if request.method == 'POST':
        # Update the thresholds with the submitted values
        for key in wifi_thresholds['threshold']:
            if key in request.form:
                wifi_thresholds['threshold'][key] = int(request.form[key])
        # Save the updated thresholds back to the JSON file
        save_json_data('json_standards/wifi_thresholds.json', wifi_thresholds)  # Save Wi-Fi thresholds
        # Redirect to the home page after saving
        return redirect(url_for('index'))

    return render_template('wifi_thresholds.html', data=wifi_thresholds)


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5003)
