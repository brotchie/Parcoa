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

#import "ParcoaPredicate.h"

@interface ParcoaPredicate ()
- (id)initWithBlock:(ParcoaPredicateBlock)block name:(NSString *)name summary:(NSString *)summary;
@end

@implementation ParcoaPredicate
@synthesize name = _name;
@synthesize summary = _summary;

+ (ParcoaPredicate *)predicateWithBlock:(ParcoaPredicateBlock)block name:(NSString *)name summary:(NSString *)summary {
    return [[ParcoaPredicate alloc] initWithBlock:block name:name summary:summary];
}

+ (ParcoaPredicate *)predicateWithBlock:(ParcoaPredicateBlock)block name:(NSString *)name summaryWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *summary = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [ParcoaPredicate predicateWithBlock:block name:name summary:summary];
}

- (ParcoaPredicate *)predicateWithName:(NSString *)name summary:(NSString *)summary {
    return [ParcoaPredicate predicateWithBlock:_block name:name summary:summary];
}

- (ParcoaPredicate *)predicateWithName:(NSString *)name summaryWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *summary = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [self predicateWithName:name summary:summary];
}

- (BOOL)check:(unichar)c {
    return _block(c);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@)", self.name, self.summary];
}

#pragma mark - Private Methods

- (id)initWithBlock:(ParcoaPredicateBlock)block name:(NSString *)name summary:(NSString *)summary {
    self = [super init];
    if (self) {
        _block = block;
        _name = name;
        _summary = summary;
    }
    return self;
}

@end
