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

#import "ParcoaExpectation.h"

@interface ParcoaExpectation ()
- (id)initWithRemaining:(NSString *)remaining expected:(NSString *)expected children:(NSArray *)children;
@end

@implementation ParcoaExpectation {
    NSUInteger _minCharactersRemaining;
}
@synthesize charactersRemaining = _charactersRemaining;
@synthesize expected = _expected;
@synthesize children = _children;

- (id)initWithRemaining:(NSString *)remaining expected:(NSString *)expected children:(NSArray *)children {
    self = [super init];
    if (self) {
        _charactersRemaining = remaining.length;
        _expected = expected;
        _children = children;
        _minCharactersRemaining = NSNotFound;
    }
    return self;
}

/** Memoized minimum number of characters remaining for all expectations
 *  below the current expectation.
 */
- (NSUInteger)minCharactersRemaining {
    if (_minCharactersRemaining == NSNotFound) {
        if (self.children) {
            _minCharactersRemaining = [[self.children valueForKeyPath:@"@min.minCharactersRemaining"] integerValue];
        } else {
            _minCharactersRemaining = _charactersRemaining;
        }
    }
    return _minCharactersRemaining;
}

+ (ParcoaExpectation *)expectationWithRemaining:(NSString *)remaining expected:(NSString *)expected children:(NSArray *)children {
    return [[ParcoaExpectation alloc] initWithRemaining:remaining expected:expected children:children];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Remaining: %u Expected: %@", self.charactersRemaining, self.expected];
}

+ (NSString *)unsatisfiable {
    return @"EOF";
}

+ (NSString *)choice {
    return @"choice";
}

@end
