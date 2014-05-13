#import "NSString+VENCore.h"

@implementation NSString (VENCore)

- (BOOL)isUSPhone {
    NSString *phoneRegex = @"^\\+?1?\\D{0,2}(\\d{3})\\D{0,2}\\D?(\\d{3})\\D?(\\d{4})$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:self];
}


- (BOOL)isEmail {
    NSString *lowerCaseSelf = [self lowercaseString];
    NSString *pattern = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [predicate evaluateWithObject:lowerCaseSelf];
}


- (BOOL)isUserId {
    NSCharacterSet *notDigitSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    return ![self isUSPhone] &&
            [self rangeOfCharacterFromSet:notDigitSet].location == NSNotFound;
}


- (VENTargetType)targetType {
    if ([self isUSPhone]) {
        return VENTargetTypePhone;
    }
    else if ([self isEmail]) {
        return VENTargetTypeEmail;
    }
    else if ([self isUserId]) {
        return VENTargetTypeUserId;
    }
    else {
        return VENTargetTypeUnknown;
    }
}


- (BOOL)hasContent {
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([[self stringByTrimmingCharactersInSet: set] length] == 0)
    {
        return NO;
    }
    return YES;
}

@end
