//
//  NSArray+VENCore.h
//  VENCore
//
//  Created by Leah Steinberg on 7/8/14.
//  Copyright (c) 2014 Venmo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (VENCore)

/**
 * Removes all elements which have NULL values from the array
 */
- (void)cleanseResponseArray;

@end


@interface NSArray (VENCore)

/**
* Returns an array containing all non-Null elements from the receiving array
* @return Array with no NULL values
*/
- (instancetype)arrayByCleansingResponseArray;

@end