// gcc -framework Foundation system_info.m -o system_info

#import <Foundation/Foundation.h>
#include <sys/utsname.h>

int main() {
    @autoreleasepool {
        // Declare uname_buf variable
        struct utsname uname_buf;
        
        // Prepare the result dictionary
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        result[@"platform"] = @"darwin";
        result[@"platform_like"] = @"darwin";

        // Gather system information

        // Hostname
        NSString *hostname = [[NSHost currentHost] localizedName];
        if (hostname) {
            result[@"hostname"] = hostname;
        }

        // System Uptime
        NSTimeInterval uptime = [[NSProcessInfo processInfo] systemUptime];
        result[@"uptime"] = @(uptime);

        // Memory Information
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        result[@"physical_memory"] = @(processInfo.physicalMemory);

        // Processor Information
        if (uname(&uname_buf) == 0) {
            NSString *processorType = [NSString stringWithUTF8String:uname_buf.machine];
            if (processorType) {
                result[@"processor_type"] = processorType;
            }
        } else {
            NSLog(@"Failed to determine the processor type");
        }

        // Convert the result dictionary to JSON data
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:&error];

        if (!jsonData) {
            NSLog(@"Error converting data to JSON: %@", error);
            return 1;
        }

        // Write the JSON data to a file
        NSString *jsonFilePath = @"json_files/system_info.json";
        BOOL success = [jsonData writeToFile:jsonFilePath atomically:YES];

        if (!success) {
            NSLog(@"Error writing JSON data to file");
            return 1;
        } else {
            NSLog(@"System information successfully written to system_info.json");
        }
    }

    return 0;
}
