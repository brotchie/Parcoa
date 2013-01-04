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

#import "ParcoaParserForward.h"

@interface ParcoaParserForward ()
- (id)initWithName:(NSString *)name summary:(NSString *)summary;
@end

@implementation ParcoaParserForward
+ (ParcoaParserForward *)forwardWithName:(NSString *)name summary:(NSString *)summary {
    return [[ParcoaParserForward alloc] initWithName:name summary:summary];
}

- (id)initWithName:(NSString *)name summary:(NSString *)summary {
    self = [super initWithBlock:^ParcoaResult *(NSString *input) {
        return [_implementation parse:input];
    } name:name summary:summary];
    return self;
}

- (void)setImplementation:(ParcoaParser *)parser {
    if (_implementation) {
        [NSException raise:@"Already Implemented" format:@"Forward declared parser's implementation is already set."];
    } else {
        _implementation = parser;
    }
}
@end
