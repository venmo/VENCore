//
// NSDictionary+VENCore
// Utility methods for deserializing JSON.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (VENCore)

/** 
 * Removes all keys which have NULL values from the dictionary
 */
- (void)cleanseResponseDictionary;

@end

@interface NSDictionary (VENCore)

/**
 * Returns the object associated with the given key
 * @param key An object identifying the value
 * @return The value associated with key, or nil if no value is associated with the key.
 */
- (id)objectOrNilForKey:(id)key;


/**
 * Returns the bool value associated with the given key
 * @param key An object identifying the value
 * @return The bool value associated with the key, or nil if no bool value can be associated with the key.
 */
- (BOOL)boolForKey:(id)key;

/**
 * Returns the string value associated with the given key
 * @param key An object identifying the value
 * @return The string value associated with the key, or nil if no string value can be associated
 * with the key.
 */
- (NSString *)stringForKey:(id)key;

/**
 * Returns a dictionary containing all non-Null key-value pairs from the receiving dictionary
 * @return Dictionary with no NULL values
 */
- (instancetype)dictionaryByCleansingResponseDictionary;

@end
