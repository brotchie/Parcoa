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

/** The primary Parcoa parser block: A function that accepts
 *  an input and returns an OK or Fail result.
 */
typedef ParcoaResult *(^ParcoaParserBlock)(NSString *input);

/** The fundamental unit of parsing is Parcoa. ParcoaParser is a
 *  lite wrapper around a ParcoaParserBlock. A ParcoaParser attempts
 *  to parse an input string, returning an OK or Fail result.
 *  All parsers within Parcoa are ParcoaParser objects.
 *
 *  - Parse a NSString using parse:.
 *  - Create new parsers using the parserWithBlock:name:summary:
 *  class method.
 */
@interface ParcoaParser : NSObject {
@private
    ParcoaParserBlock _block;
}

/// @name Properties

/** The parsers human readable name. */
@property (nonatomic, readonly) NSString *name;

/** A human readable summary of the parser. */
@property (nonatomic, readonly) NSString *summary;

/// @name Create a New Parser

/** Initialises an allocated ParcoaParser with the given ParcoaParserBlock.
 *
 *  @see parserWithBlock:name:summary:
 */
- (id)initWithBlock:(ParcoaParserBlock)block name:(NSString *)name summary:(NSString *)summary;

/** Creates a new ParcoaParser with the given ParcoaParserBlock.
 *
 *  @param block A pure function block that attempt to parse an input string
 *               then returns a ParcoaResult.
 *  @param name A human readable name.
 *  @param name A human readable summary.
 */
+ (ParcoaParser *)parserWithBlock:(ParcoaParserBlock)block name:(NSString *)name summary:(NSString *)summary;

/** parserWithBlock:name:summary: with printf style formatting
 *  for summary.
 *
 *  @see parserWithBlock:name:summary:
 */
+ (ParcoaParser *)parserWithBlock:(ParcoaParserBlock)block name:(NSString *)name summaryWithFormat:(NSString *)format, ...;

/// @name Rename an Existing Parser

/** Creates a new ParcoaParser with the receiver's block and a
 *  new name and summary. */
- (ParcoaParser *)parserWithName:(NSString *)name summary:(NSString *)summary;

/** parserWithName:summary: with printf style formatting for summary.
 *
 * @see parserWithName:summary:
 */
- (ParcoaParser *)parserWithName:(NSString *)name summaryWithFormat:(NSString *)format, ...;

/// @name Parse a String

/** Supplies the parser block with input and returns the result. */
- (ParcoaResult *)parse:(NSString *)input;

@end
