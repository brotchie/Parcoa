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

- (ParcoaParser *)or:(ParcoaParser *)right;

/** Equivalent to [Parcoa choice:self default:value]. */
- (ParcoaParser *)withDefault:(id)value;

- (ParcoaParser *)many;
- (ParcoaParser *)many1;
- (ParcoaParser *)sepBy:(ParcoaParser *)delimiter;
- (ParcoaParser *)sepBy1:(ParcoaParser *)delimiter;
- (ParcoaParser *)then:(ParcoaParser *)right;
- (ParcoaParser *)keepLeft:(ParcoaParser *)right;
- (ParcoaParser *)keepRight:(ParcoaParser *)right;
- (ParcoaParser *)between:(ParcoaParser *)left and:(ParcoaParser *)right;
- (ParcoaParser *)concat;
- (ParcoaParser *)concatMany;
- (ParcoaParser *)concatMany1;
- (ParcoaParser *)skipSurroundingSpaces;
- (ParcoaParser *)transform:(ParcoaValueTransform)transform name:(NSString *)name;
- (ParcoaParser *)valueAtIndex:(NSUInteger)index;

@end
