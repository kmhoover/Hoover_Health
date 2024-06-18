# Define the compiler and the flags
CC = gcc
CFLAGS = -framework Foundation -framework AppKit
WFLAGS = -framework Foundation -framework CoreWLAN

# List of source files in the queries directory
SOURCES = queries/bluetooth.mm queries/os_version.m queries/port_info.m queries/running_apps.m queries/system_info.m queries/wifi_info.m 

# List of executables in the queries directory
EXECUTABLES = queries/bluetooth queries/os_version queries/port_info queries/running_apps queries/system_info queries/wifi_info

# Directories
JSON_DIR = json_files
QUERY_DIR = queries

# Default target
all: $(EXECUTABLES)

# Rules to build each executable
queries/bluetooth: $(QUERY_DIR)/bluetooth.mm
	$(CC) $(CFLAGS) $(QUERY_DIR)/bluetooth.mm -o queries/bluetooth

queries/os_version: $(QUERY_DIR)/os_version.m
	$(CC) $(CFLAGS) $(QUERY_DIR)/os_version.m -o queries/os_version

queries/port_info: $(QUERY_DIR)/port_info.m
	$(CC) $(CFLAGS) $(QUERY_DIR)/port_info.m -o queries/port_info

queries/running_apps: $(QUERY_DIR)/running_apps.m
	$(CC) $(CFLAGS) $(QUERY_DIR)/running_apps.m -o queries/running_apps

queries/system_info: $(QUERY_DIR)/system_info.m
	$(CC) $(CFLAGS) $(QUERY_DIR)/system_info.m -o queries/system_info

queries/wifi_info: $(QUERY_DIR)/wifi_info.m
	$(CC) $(WFLAGS) $(QUERY_DIR)/wifi_info.m -o queries/wifi_info

# Clean target to remove generated files
clean:
	rm -f queries/bluetooth queries/os_version queries/port_info queries/running_apps queries/system_info queries/wifi_info

.PHONY: all clean run
