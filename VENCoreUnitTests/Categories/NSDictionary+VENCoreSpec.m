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

describe(@"cleanseResponseDictionary", ^{
    it(@"should remove null values from a dictionary", ^{
        NSMutableDictionary *mutableDictionary = [@{@"nullKey":[NSNull null], @"notNullKey":@"value"} mutableCopy];
        [mutableDictionary cleanseResponseDictionary];
        expect(mutableDictionary[@"nullKey"]).to.beNil();
        expect(mutableDictionary[@"notNullKey"]).to.equal(@"value");
    });
    
    it(@"should stringify all NSNumbers", ^{
        NSMutableDictionary *mutableDictionary = [@{@"numberKey": @(3),
                                                    @"numberKey2": @(12830.123),
                                                    @"stringKey": @"Hi there"} mutableCopy];
        [mutableDictionary cleanseResponseDictionary];
        
        [mutableDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            expect(obj).to.beKindOf([NSString class]);
        }];
    });
    
    it(@"should not modify NSDictionary members that dont contain NSNull/NSNumber values or NSArray members", ^{
        NSArray *array = @[@"Lucas",@"uses",@"Venmo"];
        NSDictionary *dictionary = @{@1: @"one",
                                     @2: @"two",
                                     @3: @"3"};
        NSMutableDictionary *mutableDictionary = [@{@"array": array,
                                                    @"dictionary": dictionary} mutableCopy];
        
        [mutableDictionary cleanseResponseDictionary];
        expect(mutableDictionary[@"array"]).to.beKindOf([NSArray class]);
        expect(mutableDictionary[@"dictionary"]).to.beKindOf([NSDictionary class]);

    });
    
    it(@"should not cleanse NSDictionary members that contain NSNull values and NSNumber values", ^{
        NSArray *memberArray = @[@"Lucas",@"uses",@"Venmo"];
        NSDictionary *memberDictionary = @{@1: @"one",
                                     @2: [NSNull null],
                                     @3: @3};
        NSMutableDictionary *mutableDictionary = [@{@"array": memberArray,
                                                    @"dictionary": memberDictionary} mutableCopy];
        NSDictionary *cleansedMemberDictionary = @{@1: @"one",
                                                   @3: @"3"};
        NSMutableDictionary *cleansedMutableDictionary = [mutableDictionary mutableCopy];
        [cleansedMutableDictionary setObject:cleansedMemberDictionary
                                      forKey:@"dictionary"];
        [mutableDictionary cleanseResponseDictionary];
        expect(mutableDictionary).to.equal(cleansedMutableDictionary);
    });
    
});

SpecEnd