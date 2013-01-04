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

#import "ParcoaParser.h"
#import "Parcoa+Combinators.h"

/** The parser combinators in the Parcoa+Combinators category
 *  are all pure class methods. This ParcoaParser+Combinators
 *  category adds instance methods to easily apply combinators. */
@interface ParcoaParser (Combinators)

/// @name ParcoaParser Instance Combinators

/// @see [Parcoa parser:or:]
- (ParcoaParser *)or:(ParcoaParser *)right;

/** Equivalent to [Parcoa option:default:] with
 * receiver and value as arguments. */
- (ParcoaParser *)withDefault:(id)value;

/// @see [Parcoa many:]
- (ParcoaParser *)many;

/// @see [Parcoa many1:]
- (ParcoaParser *)many1;

/// @see [Parcoa sepBy:delimiter:]
- (ParcoaParser *)sepBy:(ParcoaParser *)delimiter;

/// @see [Parcoa sepBy1:delimiter:]
- (ParcoaParser *)sepBy1:(ParcoaParser *)delimiter;

/// @see [Parcoa sepByKeep:delimiter:]
- (ParcoaParser *)sepByKeep:(ParcoaParser *)delimiter;

/// @see [Parcoa sepBy1Keep:delimiter:]
- (ParcoaParser *)sepBy1Keep:(ParcoaParser *)delimiter;

/// @see [Parcoa parser:then:]
- (ParcoaParser *)then:(ParcoaParser *)right;

/// @see [Parcoa parser:keepLeft:]
- (ParcoaParser *)keepLeft:(ParcoaParser *)right;

/// @see [Parcoa parser:keepRight:]
- (ParcoaParser *)keepRight:(ParcoaParser *)right;

/// @see [Parcoa between:parser:right:]
- (ParcoaParser *)between:(ParcoaParser *)left and:(ParcoaParser *)right;

/// @see [Parcoa concat:]
- (ParcoaParser *)concat;

/// @see [Parcoa concatMany:]
- (ParcoaParser *)concatMany;

/// @see [Parcoa concatMany1:]
- (ParcoaParser *)concatMany1;

/// @see [Parcoa skipSurroundingSpaces:]
- (ParcoaParser *)skipSurroundingSpaces;

/// @see [Parcoa parser:transform:name:]
- (ParcoaParser *)transform:(ParcoaValueTransform)transform name:(NSString *)name;

/// @see [Parcoa parser:valueAtIndex:]
- (ParcoaParser *)valueAtIndex:(NSUInteger)index;

@end
