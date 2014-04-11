#import "NSDictionary+VENCore.h"

SpecBegin(NSDictionaryVENCore)

describe(@"objectOrNilForKey:", ^{
    it(@"should return the object if it exists", ^{
        NSString *key = @"key";
        NSObject *object = [NSObject new];
        NSDictionary *d = @{key: object};
        expect([d objectOrNilForKey:key]).to.equal(object);
    });

    it(@"should return nil if the key has an NSNull object associated with it", ^{
        NSString *key = @"key";
        NSObject *object = [NSNull null];
        NSDictionary *d = @{key: object};
        expect([d objectOrNilForKey:key]).to.equal(nil);
    });

    it(@"should return nil if there is no object", ^{
        NSDictionary *d = @{@"key": @"value"};
        expect([d objectOrNilForKey:@"other_key"]).to.equal(nil);
    });
});


describe(@"boolForKey", ^{
    it(@"should return YES if the object is non-zero", ^{
        NSString *key = @"key";
        NSDictionary *d = @{key: @(1)};
        expect([d boolForKey:key]).to.equal(YES);

        d = @{key: @(-1)};
        expect([d boolForKey:key]).to.equal(YES);

        d = @{key: @(100)};
        expect([d boolForKey:key]).to.equal(YES);       
    });

    it(@"should return NO if the object is 0", ^{
        NSString *key = @"key";
        NSDictionary *d = @{key: @(0)};
        expect([d boolForKey:key]).to.equal(NO);
    });

    it(@"should return NO if the object is NSNull", ^{
        NSString *key = @"key";
        NSDictionary *d = @{key: [NSNull null]};
        expect([d boolForKey:key]).to.equal(NO);
    });

    it(@"should return NO if there is no object", ^{
        NSDictionary *d = @{@"key": @"value"};
        expect([d boolForKey:@"other_key"]).to.equal(NO);
    });
});


describe(@"stringForKey", ^{
    it(@"should return the object if it is a string", ^{
        NSString *key = @"key";
        NSString *value = @"value";
        NSDictionary *d = @{key: value};
        expect([d stringForKey:key]).to.equal(value);
    });

    it(@"should return the string representation of a positive number", ^{
        NSString *key = @"key";
        NSNumber *value = @(123.45);
        NSDictionary *d = @{key: value};
        expect([d stringForKey:key]).to.equal(@"123.45");
    });

    it(@"should return the string representation of a negative number", ^{
        NSString *key = @"key";
        NSNumber *value = @(-123.45);
        NSDictionary *d = @{key: value};
        expect([d stringForKey:key]).to.equal(@"-123.45");
    });
});

describe(@"removeAllNullValues", ^{
    it(@"should remove null values from a dictionary", ^{
        NSMutableDictionary *mutableDictionary = [@{@"nullKey":[NSNull null], @"notNullKey":@"value"}mutableCopy];
        [mutableDictionary removeAllNullValues];
        expect(mutableDictionary[@"nullKey"]).to.beNil();
        expect(mutableDictionary[@"notNullKey"]).to.equal(@"value");
    });
});

SpecEnd