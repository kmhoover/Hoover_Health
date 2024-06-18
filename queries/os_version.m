// gcc -framework Foundation os_version.m -o os_version

#import <Foundation/Foundation.h>
#include <sys/utsname.h>

int main() {
    @autoreleasepool {
        // Path to the SystemVersion.plist file
        NSString *systemVersionPath = @"/System/Library/CoreServices/SystemVersion.plist";

        // Load the contents of the plist into a dictionary
        NSDictionary *versionDict = [NSDictionary dictionaryWithContentsOfFile:systemVersionPath];

        if (!versionDict) {
            NSLog(@"Failed to read system version information");
            return 1;
        }

        // Prepare the result dictionary
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        result[@"platform"] = @"darwin";
        result[@"platform_like"] = @"darwin";

        // Determine architecture
        struct utsname uname_buf;
        if (uname(&uname_buf) == 0) {
            result[@"arch"] = [NSString stringWithUTF8String:uname_buf.machine];
        } else {
            NSLog(@"Failed to determine the OS architecture, error %d", errno);
        }

        // Extract version information from the plist
        NSString *productName = versionDict[@"ProductName"];
        NSString *productVersion = versionDict[@"ProductVersion"];
        NSString *productBuildVersion = versionDict[@"ProductBuildVersion"];

        if (productName) {
            result[@"name"] = productName;
        }
        if (productVersion) {
            result[@"version"] = productVersion;

            // Break out version parts
            NSArray *versionComponents = [productVersion componentsSeparatedByString:@"."];
            if (versionComponents.count > 0) {
                result[@"major"] = @([versionComponents[0] integerValue]);
            }
            if (versionComponents.count > 1) {
                result[@"minor"] = @([versionComponents[1] integerValue]);
            }
            if (versionComponents.count > 2) {
                result[@"patch"] = @([versionComponents[2] integerValue]);
            }
        }
        if (productBuildVersion) {
            result[@"build"] = productBuildVersion;
        }

        // Convert the result dictionary to JSON data
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:&error];

        if (!jsonData) {
            NSLog(@"Error converting data to JSON: %@", error);
            return 1;
        }

        // Write the JSON data to a file
        NSString *jsonFilePath = @"json_files/os_version.json";
        BOOL success = [jsonData writeToFile:jsonFilePath atomically:YES];

        if (!success) {
            NSLog(@"Error writing JSON data to file");
            return 1;
        } else {
            NSLog(@"OS version data successfully written to os_version.json");
        }
    }

    return 0;
}
