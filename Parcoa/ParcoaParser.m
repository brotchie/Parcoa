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

#import "ParcoaParser.h"

@implementation ParcoaParser
@synthesize name = _name;
@synthesize summary = _summary;

- (id)initWithBlock:(ParcoaParserBlock)block name:(NSString *)name summary:(NSString *)summary {
    self = [super init];
    if (self) {
        _block = block;
        _name = name;
        _summary = summary;
    }
    return self;
}

+ (ParcoaParser *)parserWithBlock:(ParcoaParserBlock)block name:(NSString *)name summary:(NSString *)summary {
    return [[ParcoaParser alloc] initWithBlock:block name:name summary:summary];
}

+ (ParcoaParser *)parserWithBlock:(ParcoaParserBlock)block name:(NSString *)name summaryWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *summary = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [ParcoaParser parserWithBlock:block name:name summary:summary];
}

- (ParcoaParser *)parserWithName:(NSString *)name summary:(NSString *)summary {
    return [ParcoaParser parserWithBlock:_block name:name summary:summary];
}

- (ParcoaParser *)parserWithName:(NSString *)name summaryWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *summary = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [self parserWithName:name summary:summary];
}

- (ParcoaResult *)parse:(NSString *)input {
    return _block(input);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@)", self.name, self.summary];
}

@end
