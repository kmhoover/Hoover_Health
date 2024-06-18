// gcc -framework Foundation -framework CoreWLAN wifi_info.m -o wifi_info

#import <Foundation/Foundation.h>
#import <CoreWLAN/CoreWLAN.h>

int main() {
    @autoreleasepool {
        // Get the default Wi-Fi interface
        CWInterface *wifiInterface = [CWWiFiClient sharedWiFiClient].interface;
        
        if (wifiInterface) {
            // Create a dictionary to store the Wi-Fi information
            NSMutableDictionary *wifiInfo = [NSMutableDictionary dictionary];
            
            // Get the current SSID (network name)
            NSString *ssid = wifiInterface.ssid;
            if (ssid) {
                wifiInfo[@"SSID"] = ssid;
            }

            // Get the BSSID (MAC address of the access point)
            NSString *bssid = wifiInterface.bssid;
            if (bssid) {
                wifiInfo[@"BSSID"] = bssid;
            }

            // Get the signal strength (RSSI)
            NSInteger rssiValue = wifiInterface.rssiValue;
            wifiInfo[@"RSSI"] = @(rssiValue);

            // Get the noise level
            NSInteger noiseLevel = wifiInterface.noiseMeasurement;
            wifiInfo[@"Noise_Level"] = @(noiseLevel);

            // Get the transmit rate
            double transmitRate = wifiInterface.transmitRate;
            wifiInfo[@"Transmit_Rate"] = @(transmitRate);

            // Get the channel information
            CWChannel *channel = wifiInterface.wlanChannel;
            if (channel) {
                wifiInfo[@"Channel"] = @(channel.channelNumber);
                wifiInfo[@"Channel_Width"] = @(channel.channelWidth);
                wifiInfo[@"Channel_Band"] = @(channel.channelBand);
            }

            // Convert the dictionary to JSON data
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:wifiInfo options:NSJSONWritingPrettyPrinted error:&error];

            if (!jsonData) {
                NSLog(@"Error converting data to JSON: %@", error);
                return 1;
            }

            // Write the JSON data to a file
            NSString *jsonFilePath = @"json_files/wifi_info.json";
            BOOL success = [jsonData writeToFile:jsonFilePath atomically:YES];

            if (!success) {
                NSLog(@"Error writing JSON data to file");
                return 1;
            } else {
                NSLog(@"Wi-Fi information successfully written to wifi_info.json");
            }
        } else {
            NSLog(@"No Wi-Fi interface found");
        }
    }

    return 0;
}
