/*
 ____
 |  _ \ __ _ _ __ ___ ___   __ _   Parcoa - Objective-C Parser Combinators
 | |_) / _` | '__/ __/ _ \ / _` |
 |  __/ (_| | | | (_| (_) | (_| |  Copyright (c) 2012,2013 James Brotchie
 |_|   \__,_|_|  \___\___/ \__,_|  https://github.com/brotchie/Parcoa
 
 
 The MIT License
 
 Copyright (c) 2012,2013 James Brotchie
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

#import "ParcoaString.h"

@implementation ParcoaString {
    NSString *s;
    NSRange r;
}

- (NSString *)string {
    return [s substringWithRange:r];
}

- (id)initWithString:(NSString *)string {
    return [self initWithString:string range:NSMakeRange(0, string.length)];
}

- (id)initWithString:(NSString *)string range:(NSRange)range{
    self = [super init];
    if (self) {
        s = string;
        r = range;
    }
    return self;
}

+ (ParcoaString *)stringWithString:(NSString *)string {
    return [[self alloc] initWithString:string];
}

/// @name Getting a String's Length
- (NSUInteger)length {
    return r.length;
}

/// @name Getting Characters and Bytes
- (unichar)characterAtIndex:(NSUInteger)index {
    return [s characterAtIndex:r.location + index];
}

/// @name Dividing Strings
- (ParcoaString *)substringFromIndex:(NSUInteger)index {
    if (r.location + index > s.length) {
        [NSException raise:NSRangeException format:@"substringFromIndex range access out of bounds."];
    }
    return [[ParcoaString alloc] initWithString:s range:NSMakeRange(r.location + index, r.length - index)];
}

- (ParcoaString *)substringToIndex:(NSUInteger)index {
    if (index != 0 && r.location + index - 1 > s.length) {
        [NSException raise:NSRangeException format:@"substringToIndex range access out of bounds: index %u.", index];
    }
    return [[ParcoaString alloc] initWithString:s range:NSMakeRange(r.location, index)];
}

- (BOOL)hasPrefix:(NSString *)prefix {
    return [s rangeOfString:prefix options:NSAnchoredSearch range:r].location != NSNotFound;
}

- (BOOL)hasSuffix:(NSString *)suffix {
    return [s rangeOfString:suffix options:NSAnchoredSearch | NSBackwardsSearch range:r].location != NSNotFound;
}


@end
