import json
import csv

def find_differences(dict1, dict2):
    differences = {}
    for key in dict1:
        if dict1[key] != dict2.get(key):
            differences[key] = {"new_value": dict1[key], "standard_value": dict2.get(key, None)}
    for key in dict2:
        if key not in dict1:
            differences[key] = {"new_value": None, "standard_value": dict2[key]}
    return differences

def value_to_string(value):
    if isinstance(value, str):
        return f'"{value}"'
    elif isinstance(value, (int, float)):
        return str(value)
    elif isinstance(value, (dict, list)):
        return json.dumps(value, indent=2)
    elif value is None:
        return "null"
    else:
        return str(value)

def dictionary_to_csv_string(dictionary):
    csv_rows = []
    for key, values in dictionary.items():
        new_value = value_to_string(values["new_value"])
        standard_value = value_to_string(values["standard_value"])
        csv_rows.append([key, new_value, standard_value])
    return csv_rows

def main():
    # Read the combined results JSON file
    with open("json_files/combined_results.json", "r") as combined_file:
        combined_results = json.load(combined_file)

    # Read the standard JSON file
    with open("json_standards/combined_standard.json", "r") as standard_file:
        standard_results = json.load(standard_file)

    # Compare the two dictionaries and find differences
    all_differences = {}
    for key in combined_results:
        combined_sub_dict = combined_results[key]
        standard_sub_dict = standard_results.get(key, {})
        if combined_sub_dict != standard_sub_dict:
            differences = find_differences(combined_sub_dict, standard_sub_dict)
            for sub_key, diff_values in differences.items():
                full_key = f"{key}.{sub_key}"
                all_differences[full_key] = diff_values

    # Write the differences to a CSV file
    csv_content = [["Key", "New Value", "Standard Value"]]
    csv_content.extend(dictionary_to_csv_string(all_differences))

    with open("differences.csv", "w", newline='', encoding="utf-8") as csv_file:
        writer = csv.writer(csv_file)
        writer.writerows(csv_content)

if __name__ == "__main__":
    main()
