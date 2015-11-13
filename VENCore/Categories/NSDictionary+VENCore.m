#import "NSDictionary+VENCore.h"
#import "NSArray+VENCore.h"
#import "NSString+VENCore.h"

#import <ISO8601/ISO8601.h>

@implementation NSMutableDictionary (VENCore)

- (void)cleanseResponseDictionary {
    for (NSString *key in [self allKeys]) {
        NSObject *object = (NSObject *) self[key];
        if (object == [NSNull null]) {
            [self removeObjectForKey:key];
        }
        else if ([object isKindOfClass:[NSNumber class]]) {
            self[key] = [((NSNumber *)object) stringValue];
        }
        else if ([object isKindOfClass:[NSDictionary class]]) {
            self[key] = [((NSDictionary *)object) dictionaryByCleansingResponseDictionary];
        }
        else if([object isKindOfClass:[NSArray class]]) {
            NSArray *array = [(NSArray *)object copy];
            self[key] = [array arrayByCleansingResponseArray];
        }
    }
}

@end

@implementation NSDictionary (VENCore)

- (id)objectOrNilForKey:(id)key {
    id object = self[key];
    return object == [NSNull null] ? nil : object;
}


- (BOOL)boolForKey:(id)key {
    id object = [self objectOrNilForKey:key];
    if ([object respondsToSelector:@selector(boolValue)]) {
        return [object boolValue];
    } else {
        return object != nil;
    }
}


- (NSString *)stringForKey:(id)key {
    id object = [self objectOrNilForKey:key];
    return [object respondsToSelector:@selector(stringValue)] ? [object stringValue] : object;
}


- (instancetype)dictionaryByCleansingResponseDictionary {

    NSMutableDictionary *dictionary  = [self mutableCopy];
    [dictionary cleanseResponseDictionary];

    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (NSString *)urlEncodedString {
    NSMutableArray *queries = [NSMutableArray new];
    NSArray *keys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString* key in keys) {
        NSString* value = self[key];
        if (value != nil) {
            [queries addObject:[NSString stringWithFormat:@"%@=%@", [self encode:key], [self encode:value]]];
        }
    }
    return [queries componentsJoinedByString:@"&"];
}

- (NSString *)encode:(id)object {

    if ([object  isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *)object;
        NSString *encodedString = [string stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        encodedString = [encodedString stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        encodedString = [encodedString stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
        return encodedString;
    }

    if ([object  isKindOfClass:[NSDate class]]) {
        NSDate *date = (NSDate *)object;
        return [date ISO8601String];
    }

    return [NSString stringWithFormat:@"%@", object];
}

@end

