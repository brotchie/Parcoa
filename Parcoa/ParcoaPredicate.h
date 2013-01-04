/*
  ____
 |  _ \ __ _ _ __ ___ ___   __ _   Parcoa - Objective-C Parser Combinators
 | |_) / _` | '__/ __/ _ \ / _` |
 |  __/ (_| | | | (_| (_) | (_| |  Copyright (c) 2012 James Brotchie
 |_|   \__,_|_|  \___\___/ \__,_|  https://github.com/brotchie/Parcoa
 
 
 The MIT License
 
 Copyright (c) 2012 James Brotchie
 - brotchie@gmail.com
 - @brotchie
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */
#import <Foundation/Foundation.h>

/** The pure function wrapped by ParcoaPredicate objects.
 * Takes a unichar and returns either TRUE or FALSE. */
typedef BOOL (^ParcoaPredicateBlock)(unichar x);

/** A wrapper around a ParcoaPredicateBlock.
 
  For example, to create a predicate that matches the unichars 'a' and 'b':
 
      [ParcoaPredicate predicateWithBlock:^BOOL(unichar x) {
          return x == 'a' || x == 'b';
      } name:@"a|b" summary:@"'a' or 'b'"];
 
 */
@interface ParcoaPredicate : NSObject {
@private
    ParcoaPredicateBlock _block;
}

/// @name Properties

/** The predicate's human readable name. */
@property (nonatomic, readonly) NSString *name;

/** A human readable summary of the predicate. */
@property (nonatomic, readonly) NSString *summary;

/// @name Checking a Predicate

/** Applied the predicate block to c and returns the result. */
- (BOOL)check:(unichar)c;

/** Creates a new ParcoaPredicate with the given predicate block, name and summary. */
+ (ParcoaPredicate *)predicateWithBlock:(ParcoaPredicateBlock)block name:(NSString *)name summary:(NSString *)summary;

/** predicateWithBlock:name:summary with printf style formatting for summary. */
+ (ParcoaPredicate *)predicateWithBlock:(ParcoaPredicateBlock)block name:(NSString *)name summaryWithFormat:(NSString *)format, ...;

/// @name Rename an Existing Predicate

/** Creates a new ParcoaPredicate with the receiver's block and a new
 * name and summary. */
- (ParcoaPredicate *)predicateWithName:(NSString *)name summary:(NSString *)summary;

/** predicateWithName:summary: with printf style formatting for summary. */
- (ParcoaPredicate *)predicateWithName:(NSString *)name summaryWithFormat:(NSString *)format, ...;
@end
