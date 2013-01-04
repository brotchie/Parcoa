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

#import "Parcoa.h"
#import "ParcoaParser.h"
#import "ParcoaPredicate.h"

@interface Parcoa (Primitives)

/** @name Character and String Parsers */

/** A single unicode character that satisifes the supplied
 *  predicate.
 */
+ (ParcoaParser *)satisfy:(ParcoaPredicate *)predicate;

/** A unicode character literal.
 */
+ (ParcoaParser *)unichar:(unichar)c;

/** A string literal.
 */
+ (ParcoaParser *)string:(NSString *)string;

/** A string literal; doesn't consume input.
 */
+ (ParcoaParser *)peek:(NSString *)string;

/** Any n unicode characters.
 */
+ (ParcoaParser *)take:(NSUInteger)n;

/** A single character that a member of the set. */
+ (ParcoaParser *)oneOf:(NSString *)set;

/** A single character that isn't a member of the set. */
+ (ParcoaParser *)noneOf:(NSString *)set;

/** Parses input while the supplied predicate is true.
 */
+ (ParcoaParser *)takeWhile:(ParcoaPredicate *)condition;

/** Parses input while the supplied predicate is true; the
 *  predicate must be true for at least one character
 */
+ (ParcoaParser *)takeWhile1:(ParcoaPredicate *)condition;

/* Parses input until the supplied predicate is true.
 */
+ (ParcoaParser *)takeUntil:(ParcoaPredicate *)condition;

/** Returns a [NSNumber numberWithBool:TRUE] if no input
 *  remains; FALSE otherwise.
 */
+ (ParcoaParser *)atEnd;

/** OK if no input remains, Fail otherwise.
 */
+ (ParcoaParser *)endOfInput;

/** Parses any input whitespace. */
+ (ParcoaParser *)spaces;

/** Parses a single whitespace character. */
+ (ParcoaParser *)space;

/** Parses a newline '\n' character. */
+ (ParcoaParser *)newline;

/** Parses a tab '\t' character. */
+ (ParcoaParser *)tab;

/** Parses any uppercase unicode character. */
+ (ParcoaParser *)upper;

/** Parses any lowercase unicode character. */
+ (ParcoaParser *)lower;

/** Parses any alpha numeric unicode character. */
+ (ParcoaParser *)alphaNum;

/** Parses any letter unicode character. */
+ (ParcoaParser *)letter;

/** Parses any digit unicode character. */
+ (ParcoaParser *)digit;

/** Parses any hex digit: {0123456789ABCDEFabcdef}. */
+ (ParcoaParser *)hexDigit;

/** Parses any unicode character. */
+ (ParcoaParser *)anyUnichar;
@end
