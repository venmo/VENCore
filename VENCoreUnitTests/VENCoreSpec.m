#import "VENCore.h"
#import "VENHTTP.h"
#import "VENUser.h"

NSString *accessToken;
NSDictionary *responseDictionary;
NSString *responseString;
NSURL *baseURL;
VENCore *core;
NSString *path;

SpecBegin(VENCore)

[Expecta setAsynchronousTestTimeout:1];

describe(@"Shared Instances of VENCore should persist", ^{

    it(@"should set a 'defaultCore' and be retrievable", ^{
        VENCore *newCore = [[VENCore alloc] init];
        [VENCore setDefaultCore:newCore];

        expect([VENCore defaultCore]).to.equal(newCore);
    });

    it(@"should overwrite an existing default core when a new one is set", ^{
        VENCore *oldCore = [[VENCore alloc] init];
        [VENCore setDefaultCore:oldCore];

        VENCore *newCore = [[VENCore alloc] init];
        [VENCore setDefaultCore:newCore];

        expect([VENCore defaultCore]).to.equal(newCore);
    });

    it(@"should release an old core after setting a new core", ^{
#pragma diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"
        __weak VENCore *oldCore = [[VENCore alloc] init];
        [VENCore setDefaultCore:oldCore];
        expect([VENCore defaultCore]).to.equal(oldCore);

        [VENCore setDefaultCore:nil];

        expect(oldCore).will.equal(nil);
#pragma diagnostic pop

    });

    it(@"should clear out the defaultCore when set to nil", ^{
        VENCore *newCore = [[VENCore alloc] init];
        [VENCore setDefaultCore:newCore];
        [VENCore setDefaultCore:nil];
        expect([VENCore defaultCore]).to.equal(nil);
    });

});


SpecEnd