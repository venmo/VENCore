#import "NSDictionary+VENCore.h"


@implementation NSMutableDictionary (VENCore)

- (void)cleanseResponseDictionary {
    for (NSString *key in [self allKeys]) {
        if (self[key] == [NSNull null]) {
            [self removeObjectForKey:key];
        }
        else if ([(NSObject *)self[key] isKindOfClass:[NSNumber class]]) {
            self[key] = [((NSNumber *)self[key]) stringValue];
        }
        else if ([(NSObject *)self[key] isKindOfClass:[NSDictionary class]]) {
            self[key] = [((NSDictionary *)self[key]) dictionaryByCleansingResponseDictionary];
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

@end

