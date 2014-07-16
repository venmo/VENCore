#import "NSArray+VENCore.h"
#import "NSDictionary+VENCore.h"

@implementation NSMutableArray (VENCore)

- (void)cleanseResponseArray
{
    NSMutableArray *elementsToRemoveArray = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for (NSUInteger i=0; i<[self count]; i++) {
        if ([self[i] isKindOfClass:[NSNumber class]]) {
            self[i] = [(NSNumber *)self[i] stringValue];
        }
        else if (self[i] == [NSNull null]) {
            [elementsToRemoveArray addObject:self[i]];
        }
        else if ([self[i] isKindOfClass:[NSDictionary class]]) {
            self[i] = [(NSMutableDictionary *)self[i] dictionaryByCleansingResponseDictionary];
        }
        else if ([self[i] isKindOfClass:[NSArray class]]) {
            self[i] = [(NSArray *)self[i] arrayByCleansingResponseArray];
        }
    }
    for (NSObject *objectToRemove in elementsToRemoveArray) {
        [self removeObject:objectToRemove];
    }
}

@end

@implementation NSArray (VENCore)

- (instancetype)arrayByCleansingResponseArray
{
    NSMutableArray *array = [self mutableCopy];
    [array cleanseResponseArray];
    return [NSArray arrayWithArray:array];
}

@end
