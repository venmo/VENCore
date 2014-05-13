#import "UIDevice+VENCore.h"
#import <sys/sysctl.h>

NSString *const VENUserDefaultsKeyDeviceID = @"VenmoDeviceID";

@implementation UIDevice (VENCore)


- (NSString *)VEN_platformString {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}


- (NSString *)VEN_deviceIDString {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *uniqueIdentifier = [userDefaults stringForKey:VENUserDefaultsKeyDeviceID];
    if (!uniqueIdentifier) {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        uniqueIdentifier = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
        CFRelease(uuid);
        [userDefaults setObject:uniqueIdentifier forKey:VENUserDefaultsKeyDeviceID];
        [userDefaults synchronize];
    }
    return uniqueIdentifier;
}

@end
