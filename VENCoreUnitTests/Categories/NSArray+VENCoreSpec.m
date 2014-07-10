#import "NSArray+VENCore.h"

SpecBegin(NSArrayVENCore)

describe(@"stringForElement", ^{
    it(@"should return the array untouched if all elements are strings", ^{
        NSString *firstElement = @"elementOne";
        NSString *secondElement = @"elementTwo";
        NSArray *array = @[firstElement, secondElement];
        [array arrayByCleansingResponseArray];
        expect([array objectAtIndex:0]).to.equal(firstElement);
        expect([array objectAtIndex:1]).to.equal(secondElement);
    });
});

describe(@"cleanseResponseArray", ^{
    it(@"should remove null values from an array", ^{
        NSMutableArray *mutableArray = [@[[NSNull null], @"notNull", @"alsoNotNull"] mutableCopy];
        [mutableArray cleanseResponseArray];
        [mutableArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            expect(obj).to.beKindOf([NSString class]);
        }];
    });

    it(@"should stringify all NSNumbers", ^{
        NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
        [mutableArray addObject:@"thisIsAString"];
        [mutableArray addObject:@"alsoAString"];
        [mutableArray addObject:@3];
        [mutableArray addObject:@44];
        [mutableArray cleanseResponseArray];
        [mutableArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            expect(obj).to.beKindOf([NSString class]);
        }];
    });

    it(@"should not modify NSArray memebers that dont contain NSNull/NSNumber values or NSArray members", ^{
        NSArray *array = @[@"Lucas",@"uses",@"Venmo"];
        NSDictionary *dictionary = @{@1: @"one",
                                     @2: @"two",
                                     @3: @"3"};
        NSMutableArray *mutableArray = [@[@{@"array": array,
                                            @"dictionary": dictionary}] mutableCopy];
        [mutableArray cleanseResponseArray];
        expect(mutableArray).to.beKindOf([NSArray class]);
        expect(mutableArray[0][@"array"]).to.beKindOf([NSArray class]);
        expect(mutableArray[0][@"dictionary"]).to.beKindOf([NSDictionary class]);
    });

    it(@"should cleanse NSDictionary and NSArray members that contain NSNull/NSNumber values", ^{
        NSArray *memberArray = @[@"Lucas",@"uses",@"Venmo"];
        NSDictionary *memberDictionary = @{@1: @"one",
                                           @2: [NSNull null],
                                           @3: @3};
        NSArray *array = @[memberArray, memberDictionary];
        NSMutableArray *mutableArray = [array mutableCopy];
        [mutableArray cleanseResponseArray];
        NSDictionary *cleansedMemberDictionary = @{@1: @"one",
                                                   @3: @"3"};
        NSArray *cleansedArray = @[memberArray, cleansedMemberDictionary];
        NSMutableArray *cleansedMutableArray = [cleansedArray mutableCopy];
        expect(mutableArray).to.equal(cleansedMutableArray);
    });
});

SpecEnd
