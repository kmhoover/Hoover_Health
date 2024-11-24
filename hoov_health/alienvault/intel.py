import requests
import json

# Replace with your API key
API_KEY = "148018c106672f902351c281333a69c0fa36ff77866f0a9d7ffd58daaf97e0ce"

# Base URL for OTX API
BASE_URL = "https://otx.alienvault.com/api/v1"

# Headers for the API request
HEADERS = {
    "X-OTX-API-KEY": API_KEY,
    "Content-Type": "application/json"
}

def get_pulses():
    """Fetches the latest pulses from OTX."""
    endpoint = f"{BASE_URL}/pulses/subscribed"
    try:
        response = requests.get(endpoint, headers=HEADERS)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching pulses: {e}")
        return None

def search_indicator(indicator_type, indicator_value):
    """Searches for a specific indicator on OTX."""
    endpoint = f"{BASE_URL}/indicators/{indicator_type}/{indicator_value}"
    try:
        response = requests.get(endpoint, headers=HEADERS)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error searching indicator: {e}")
        return None
    
def save_to_file(data, filename):
    """Saves JSON data to a file."""
    try:
        with open(filename, "w") as file:
            json.dump(data, file, indent=4)
        print(f"Data successfully saved to {filename}")
    except IOError as e:
        print(f"Error writing to file {filename}: {e}")

# Example Usage
if __name__ == "__main__":
    # Fetch the latest pulses
    pulses = get_pulses()
    if pulses:
        save_to_file(pulses, "pulses.json")

    # Search for an IP address
    indicator_data = search_indicator("IPv4", "8.8.8.8")
    if indicator_data:
        save_to_file(indicator_data, "indicator.json")
