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

/** An immutable context tree that captures the state
 *  of a failed parser. */
@interface ParcoaExpectation : NSObject
/** The number of input characters remaining. */
@property (readonly) NSUInteger charactersRemaining;

/** A string describing what the parser expected.
 *  If the parser failed then this explains what text would
 *  have satisfied the parser, otherwise it explains what
 *  input would have allowed the parser to match more input
 *  than it did. */
@property (readonly) NSString *expected;

/** An array containing ParcoaFailContext children. */
@property (readonly) NSArray *children;

/** Creates an immutable ParcoFailContext. */
+ (ParcoaExpectation *)expectationWithRemaining:(NSString *)remaining expected:(NSString *)expected children:(NSArray *)children;

/** The minimum value of charactersRemaining for this context
 *  and all its chilsren. This property is memoized such that
 *  subsequent calls are costless. */
- (NSUInteger)minCharactersRemaining;

/** An expectation string indicating that there exists no input that would have
 *  allowed the parsers to consume more input. */
+ (NSString *)unsatisfiable;
+ (NSString *)choice;
@end