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

#import "ParcoaParser+Combinators.h"

@implementation ParcoaParser (Combinators)

- (ParcoaParser *)transform:(ParcoaValueTransform)transform name:(NSString *)name {
    return [Parcoa parser:self transform:transform name:name];
}

- (ParcoaParser *)valueAtIndex:(NSUInteger)index {
    return [Parcoa parser:self valueAtIndex:index];
}

- (ParcoaParser *)keepLeft:(ParcoaParser *)right {
    return [Parcoa keepLeft:self right:right];
}

- (ParcoaParser *)keepRight:(ParcoaParser *)right {
    return [Parcoa keepRight:self right:right];
}

- (ParcoaParser *)sepBy:(ParcoaParser *)delimiter {
    return [Parcoa sepBy:self delimiter:delimiter];
}

- (ParcoaParser *)sepBy1:(ParcoaParser *)delimiter {
    return [Parcoa sepBy1:self delimiter:delimiter];
}

- (ParcoaParser *)between:(ParcoaParser *)left and:(ParcoaParser *)right {
    return [Parcoa between:left parser:self right:right];
}

- (ParcoaParser *)skipSurroundingSpaces {
    return [Parcoa skipSurroundingSpaces:self];
}

- (ParcoaParser *)or:(ParcoaParser *)right {
    return [Parcoa choice:@[self, right]];
}

- (ParcoaParser *)then:(ParcoaParser *)right {
    return [Parcoa sequential:@[self, right]];
}

- (ParcoaParser *)many {
    return [Parcoa many:self];
}

- (ParcoaParser *)many1 {
    return [Parcoa many1:self];
}

- (ParcoaParser *)concat {
    return [Parcoa concat:self];
}

- (ParcoaParser *)concatMany {
    return [Parcoa concatMany:self];
}
@end
