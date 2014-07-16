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
