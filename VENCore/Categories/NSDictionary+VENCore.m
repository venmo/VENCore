#import "NSDictionary+VENCore.h"


@implementation NSMutableDictionary (VENCore)

- (void)removeAllNullValues {
    for (NSString *key in [self allKeys]) {
        if (self[key] == [NSNull null]) {
            [self removeObjectForKey:key];
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


- (instancetype)dictionaryByRemovingAllNullObjects {

    if ([self isKindOfClass:[NSMutableDictionary class]]) {
        [(NSMutableDictionary *)self removeAllNullValues];
        return self;
    }

    NSMutableDictionary *dictionary  = [self mutableCopy];
    [dictionary removeAllNullValues];

    return [[self class] dictionaryWithDictionary:dictionary];
}

@end

