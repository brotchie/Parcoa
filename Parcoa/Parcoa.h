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
#import "ParcoaResult.h"

/** The primary Parcoa parser type: A function that accepts
 *  an input and returns an OK or Fail result.
 */
typedef ParcoaResult *(^ParcoaParser)(NSString *input);

/** Any predicate that returns a boolean when fed
 *  an unicode character.
 */
typedef BOOL (^ParcoaUnicharPredicate)(unichar);

@interface Parcoa : NSObject

/** @name Running a Parser */

/** Runs a parser on the input. On failure, a traceback is written
 *  to debug output using NSLog.
 */
+ (ParcoaResult *)runParserWithTraceback:(ParcoaParser)parser input:(NSString *)input;

/** @name Adding Annotations */

/** Injects expected into the parsing context when the wrapper parser fails.
 *  Use this to give "real world" labels to parsers.
 */
+ (ParcoaParser)annotate:(ParcoaParser)parser expected:(NSString *)expected;

/** The same as annotate:expected: except generates the expected string
 *  using a printf style format string.
 */
+ (ParcoaParser)annotate:(ParcoaParser)parser expectedWithFormat:(NSString *)format, ...;

/** @name Basic Parsing */

/** A unicode character literal.
 */
+ (ParcoaParser)unichar:(unichar)c;

/** A string literal.
 */
+ (ParcoaParser)string:(NSString *)c;

/** A string literal; doesn't consume input.
 */
+ (ParcoaParser)peek:(NSString *)c;

/** Any n unicode characters.
 */
+ (ParcoaParser)take:(NSUInteger)n;

+ (ParcoaParser)oneOf:(NSString *)set;
+ (ParcoaParser)noneOf:(NSString *)set;

/** A single unicode character that satisifes the supplied
 *  predicate.
 */
+ (ParcoaParser)satisfy:(ParcoaUnicharPredicate)condition;

/** Parses input while the supplied predicate is true.
 */
+ (ParcoaParser)takeWhile:(ParcoaUnicharPredicate)condition;

/** Parses input while the supplied predicate is true; the
 *  predicate must be true for at least one character
 */
+ (ParcoaParser)takeWhile1:(ParcoaUnicharPredicate)condition;

/* Parses input until the supplied predicate is true.
 */
+ (ParcoaParser)takeUntil:(ParcoaUnicharPredicate)condition;

/* Parses input while input characters are in the supplied
 * character set.
 */
+ (ParcoaParser)takeWhileInCharacterSet:(NSCharacterSet *)set;

/* Parses input while input characters are in the supplied
 * character set. The input stream must contain at least one
 * matched character.
 */
+ (ParcoaParser)takeWhile1InCharacterSet:(NSCharacterSet *)set;

/* Parses input while input characters are members of the
 * supplied string.
 */
+ (ParcoaParser)takeWhileInClass:(NSString *)unichars;

/* Parses input while input characters are members of the
 * supplied string. The input stream must contain at least one
 * matched character.
 */
+ (ParcoaParser)takeWhile1InClass:(NSString *)unichars;

/** Returns a [NSNumber numberWithBool:TRUE] if no input
 *  remains; FALSE otherwise.
 */
+ (ParcoaParser)atEnd;

/** OK if no input remains, Fail otherwise.
 */
+ (ParcoaParser)endOfInput;

/** Parses any input whitespace. */
+ (ParcoaParser)spaces;

/** Parses a single whitespace character. */
+ (ParcoaParser)space;

/** Parses a newline '\n' character. */
+ (ParcoaParser)newline;

/** Parses a tab '\t' character. */
+ (ParcoaParser)tab;

/** Parses any uppercase unicode character. */
+ (ParcoaParser)upper;

/** Parses any lowercase unicode character. */
+ (ParcoaParser)lower;

/** Parses any alpha numeric unicode character. */
+ (ParcoaParser)alphaNum;

/** Parses any letter unicode character. */
+ (ParcoaParser)letter;

/** Parses any digit unicode character. */
+ (ParcoaParser)digit;

/** Parses any hex digit: {0123456789ABCDEFabcdef}. */
+ (ParcoaParser)hexDigit;

/** Parses any unicode character. */
+ (ParcoaParser)anyUnichar;

/** Creates a predicate that returns TRUE for the
 *  the supplied unicode character. */
+ (ParcoaUnicharPredicate)isUnichar:(unichar)c;

/** Returns TRUE for any characters in the supplied character set. */
+ (ParcoaUnicharPredicate)inCharacterSet:(NSCharacterSet *)set;

/** Returns TRUE for any characters in the supplied string. */
+ (ParcoaUnicharPredicate)inClass:(NSString *)unichars;

/** Inverts the predicate. */
+ (ParcoaUnicharPredicate)not:(ParcoaUnicharPredicate)predicate;

/** Returns TRUE for any whitespace character. */
+ (ParcoaUnicharPredicate)isSpace;

@end

/** Macros for forward declaration of recursive rules. */

#define __ParcoaMacroConcat(A,B) A ## B
#define __ParcoaForwardVariable(NAME) __ParcoaMacroConcat(__parcoa_forward_impl_,NAME)

#define ParcoaForwardDeclaration(NAME) \
__block ParcoaParser __ParcoaForwardVariable(NAME); \
ParcoaParser NAME = ^ParcoaResult *(NSString *input) { \
return __ParcoaForwardVariable(NAME)(input); \
}

#define ParcoaForwardImpl(NAME) __ParcoaForwardVariable(NAME)
