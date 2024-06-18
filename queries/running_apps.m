// gcc -framework Foundation -framework AppKit running_apps.m -o running_apps

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

int main() {
    @autoreleasepool {
        // results arrat
        NSMutableArray *appsArray = [NSMutableArray array];

        // Get the shared workspace
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];

        // Get the list of running applications
        NSArray<NSRunningApplication *> *runningApplications = [workspace runningApplications];

   
        for (NSRunningApplication *app in runningApplications) {
            // Prepare dictionary to store application information
            NSMutableDictionary *appInfo = [NSMutableDictionary dictionary];

            // Get the process ID
            appInfo[@"pid"] = @(app.processIdentifier);

            // Get the bundle identifier
            if (app.bundleIdentifier) {
                appInfo[@"bundle_identifier"] = app.bundleIdentifier;
            } else {
                appInfo[@"bundle_identifier"] = @"";
            }

            // Check if the application is active
            BOOL isActive = app.isActive;
            appInfo[@"is_active"] = @(isActive);


            [appsArray addObject:appInfo];
        }

        // Convert the result array to JSON data
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:appsArray options:NSJSONWritingPrettyPrinted error:&error];

        if (!jsonData) {
            NSLog(@"Error converting data to JSON: %@", error);
            return 1;
        }

        // Write the JSON data to a file
        NSString *jsonFilePath = @"json_files/running_apps.json";
        BOOL success = [jsonData writeToFile:jsonFilePath atomically:YES];

        if (!success) {
            NSLog(@"Error writing JSON data to file");
            return 1;
        } else {
            NSLog(@"Running application information successfully written to running_apps.json");
        }
    }

    return 0;
}
