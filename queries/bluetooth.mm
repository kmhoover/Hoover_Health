 // gcc -framework Foundation -framework AppKit bluetooth.mm -o bluetooth

#import <Foundation/Foundation.h>
#import <AppKit/NSDocument.h>

// declare interface
@interface SPDocument : NSDocument {}
- (id)reportForDataType:(id)arg1;
@end

int main() {
  //define file path
  CFURLRef bundle_url = CFURLCreateWithFileSystemPath(
      kCFAllocatorDefault,
      CFSTR("/System/Library/PrivateFrameworks/SPSupport.framework"),
      kCFURLPOSIXPathStyle,
      true);

  if (bundle_url == nullptr) {
    NSLog(@"Error parsing SPSupport bundle URL");
    return 0;
  }

  //load framewok bundle
  CFBundleRef bundle = CFBundleCreate(kCFAllocatorDefault, bundle_url);
  CFRelease(bundle_url);
  if (bundle == nullptr) {
    NSLog(@"Error opening SPSupport bundle");
    return 0;
  }

  CFBundleLoadExecutable(bundle);

  // suppress compiler warnings
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"


  // Does the `SPDocument` class exist?
  id cls = NSClassFromString(@"SPDocument");
  if (cls == nullptr) {
    NSLog(@"Could not load SPDocument class");
    CFBundleUnloadExecutable(bundle);
    CFRelease(bundle);
    return 0;
  }

  // Does the `SPDocument` does it respond to the `new` method?
  SEL sel = @selector(new);
  if (![cls respondsToSelector:sel]) {
    NSLog(@"SPDocument does not respond to new selector");
    CFBundleUnloadExecutable(bundle);
    CFRelease(bundle);
    return 0;
  }

  // Did calling `new` actually result in something being returned?
  id document = [cls performSelector:sel];
  if (document == nullptr) {
    NSLog(@"[SPDocument new] returned null");
    CFBundleUnloadExecutable(bundle);
    CFRelease(bundle);
    return 0;
  }

  #pragma clang diagnostic pop

  // access bluetooth data (only controller_properties)
  NSDictionary* data = [[[document reportForDataType:@"SPBluetoothDataType"] objectForKey:@"_items"] lastObject];
  //NSDictionary* properties = [report objectForKey:@"controller_properties"];
  //NSDictionary* device = [report objectForKey:@"device_connected"];


  if (data != nullptr) {
    // Convert the dictionary to JSON data
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];

    if (!jsonData) {
      NSLog(@"Error converting data to JSON: %@", error);
    } else {
      NSString *jsonFilePath = @"json_files/bluetooth.json";
      
      // Write the JSON data to the file
      BOOL success = [jsonData writeToFile:jsonFilePath atomically:YES];
      
      if (!success) {
        NSLog(@"Error writing JSON data to file");
      } else {
        NSLog(@"Bluetooth data successfully written to bluetooth.json");
      }
    }
  } else {
    NSLog(@"No Bluetooth data found");
  }

  //NSLog(@"%@", data);

  // clean memory
  CFRelease((__bridge CFTypeRef)document);
  CFBundleUnloadExecutable(bundle);
  CFRelease(bundle);

  return 0;
}
