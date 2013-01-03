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

#import "ParcoaResult.h"
#import "NSString+Parcoa.h"

@interface ParcoaFailContext ()
- (id)initWithRemaining:(NSString *)remaining expected:(NSString *)expected children:(NSArray *)children;
@end

@implementation ParcoaFailContext {
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

/** Memoized minimum number of characters remaining for all contexts
 *  below the current context.
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

+ (ParcoaFailContext *)contextWithRemaining:(NSString *)remaining expected:(NSString *)expected children:(NSArray *)children {
    return [[ParcoaFailContext alloc] initWithRemaining:remaining expected:expected children:children];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Remaining: %u Expected: %@", self.charactersRemaining, self.expected];
}

@end

@interface ParcoaResult ()
- (id)initOK:(id)value residual:(NSString *)residual;
- (id)initFail:(ParcoaFailContext *)context;
@end

@implementation ParcoaResult

@synthesize type = _type;
@synthesize value = _value;
@synthesize residual = _residual;
@synthesize context = _context;

- (id)initOK:(id)value residual:(NSString *)residual{
    self = [super init];
    if (self) {
        _type = ParcoaResultOK;
        _value = value;
        _residual = residual;
        _context = nil;
    }
    return self;
}

- (id)initFail:(ParcoaFailContext *)context {
    self = [super init];
    if (self) {
        _type = ParcoaResultFail;
        _value = nil;
        _residual = nil;
        _context = context;
    }
    return self;
}

+ (ParcoaResult *)ok:(id)value residual:(NSString *)residual{
    return [[ParcoaResult alloc] initOK:value residual:residual];
}

+ (ParcoaResult *)failWithRemaining:(NSString *)remaining expected:(NSString *)expected {
    return [[ParcoaResult alloc] initFail:[ParcoaFailContext contextWithRemaining:remaining expected:expected children:nil]];
}

+ (ParcoaResult *)failWithRemaining:(NSString *)remaining expectedWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *expected = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [ParcoaResult failWithRemaining:remaining expected:expected];
}

+ (ParcoaResult *)failWithFailures:(NSArray *)failures remaining:(NSString *)remaining expected:(NSString *)expected {
    NSArray *contexts = [failures valueForKey:@"context"];
    return [[ParcoaResult alloc] initFail:[ParcoaFailContext contextWithRemaining:remaining expected:expected children:contexts]];
}

- (ParcoaResult *)prependContextWithRemaining:(NSString *)remaining expected:(NSString *)expected {
    NSAssert(self.isFail, @"Prepending context only valid for fail results.");
    return [[ParcoaResult alloc] initFail:[ParcoaFailContext contextWithRemaining:remaining expected:expected children:@[self.context]]];
}

- (ParcoaResult *)prependContextWithRemaining:(NSString *)remaining expectedWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *expected = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [self prependContextWithRemaining:remaining expected:expected];
}

- (BOOL)isFail {
    return _type == ParcoaResultFail;
}

- (BOOL)isOK {
    return _type == ParcoaResultOK;
}

- (NSString *)description {
    if ([self isOK]) {
        return [NSString stringWithFormat:@"ParcoaResult(OK,%@,%@)", self.value, self.residual];
    } else {
        return [NSString stringWithFormat:@"ParcoaResult(Fail,%@)", self.context];
    }
}

#pragma mark - Traceback Generation

- (NSString *)traceback:(NSString *)input {
    return [self traceback:input full:YES];
}

- (NSString *)traceback:(NSString *)input full:(BOOL)full {
    return [self reduceTraceback:input context:self.context indent:0 full:full];
}

- (NSString *)reduceTraceback:(NSString *)input context:(ParcoaFailContext *)context indent:(NSUInteger)indent full:(BOOL)full{
    NSMutableString *tb = [NSMutableString stringWithString:[self formatTraceback:input context:context indent:indent]];
    
    if (full) {
        [context.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [tb appendString:[self reduceTraceback:input context:obj indent:indent+1 full:YES]];
        }];
    } else {
        if (context.children) {
            NSUInteger minCharactersRemaining = [[context.children valueForKeyPath:@"@min.minCharactersRemaining"] integerValue];
            NSUInteger bestChildIndex = [context.children indexOfObjectPassingTest:^BOOL(ParcoaFailContext *obj, NSUInteger idx, BOOL *stop) {
                return obj.minCharactersRemaining == minCharactersRemaining;
            }];
            [tb appendString:[self reduceTraceback:input context:context.children[bestChildIndex] indent:indent+1 full:NO]];
        }
    }
    return tb;
}

- (NSString *)formatTraceback:(NSString *)input context:(ParcoaFailContext *)context indent:(NSUInteger)indent {
    ParcoaLineColumn position = [input lineAndColumnForIndex:input.length - context.charactersRemaining];
    NSString *tabs = [@"" stringByPaddingToLength:indent withString:@"\t" startingAtIndex:0];
    return [NSString stringWithFormat:@"%@Line %u Column %u: %@\n", tabs, position.line, position.column, context.expected];
}

@end
