// gcc -framework Foundation port_info.m -o port_info

#import <Foundation/Foundation.h>
#include <netdb.h>

int main() {
    @autoreleasepool {
        // Prepare the result array to store port information
        NSMutableArray *portsArray = [NSMutableArray array];

        // Define the range of port numbers for scanning
        int startPort = 1;
        int endPort = 500;

        for (int port = startPort; port <= endPort; port++) {
            // Get port service information
            struct servent *service = getservbyport(htons(port), "tcp");
            
            if (service != NULL) {
                // Prepare dictionary to store port information
                NSMutableDictionary *portInfo = [NSMutableDictionary dictionary];
                portInfo[@"port"] = @(port);
                portInfo[@"name"] = [NSString stringWithUTF8String:service->s_name];
                portInfo[@"protocol"] = @"tcp"; // only tcp for now
                
                // Add port information to the result array
                [portsArray addObject:portInfo];
            }
        }

        // Convert the result array to JSON data
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:portsArray options:NSJSONWritingPrettyPrinted error:&error];

        if (!jsonData) {
            NSLog(@"Error converting data to JSON: %@", error);
            return 1;
        }

        // Write the JSON data to a file
        NSString *jsonFilePath = @"json_files/port_info.json";
        BOOL success = [jsonData writeToFile:jsonFilePath atomically:YES];

        if (!success) {
            NSLog(@"Error writing JSON data to file");
            return 1;
        } else {
            NSLog(@"Port information successfully written to port_info.json");
        }
    }

    return 0;
}
