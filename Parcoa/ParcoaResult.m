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

@interface ParcoaResult ()
- (id)initOK:(id)value residual:(NSString *)residual expectation:(ParcoaExpectation *)expectation;
- (id)initFail:(ParcoaExpectation *)expectation;
@end

@implementation ParcoaResult

@synthesize type = _type; 
@synthesize value = _value;
@synthesize residual = _residual;
@synthesize expectation = _expectation;

- (id)initOK:(id)value residual:(NSString *)residual expectation:(ParcoaExpectation *)expectation{
    self = [super init];
    if (self) {
        _type = ParcoaResultOK;
        _value = value;
        _residual = residual;
        _expectation = expectation;
    }
    return self;
}

- (id)initFail:(ParcoaExpectation *)expectation {
    self = [super init];
    if (self) {
        _type = ParcoaResultFail;
        _value = nil;
        _residual = nil;
        _expectation = expectation;
    }
    return self;
}

+ (ParcoaResult *)ok:(id)value residual:(NSString *)residual expected:(NSString *)expected{
    return [[ParcoaResult alloc] initOK:value residual:residual expectation:[ParcoaExpectation expectationWithRemaining:residual expected:expected children:nil]];
}

+ (ParcoaResult *)ok:(id)value residual:(NSString *)residual expectedWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *expected = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [ParcoaResult ok:value residual:residual expected:expected];
}

+ (ParcoaResult *)okWithChildren:(NSArray *)children value:(id)value residual:(NSString *)residual expected:(NSString *)expected {
    NSArray *expectations = [children valueForKey:@"expectation"];
    return [[ParcoaResult alloc] initOK:value residual:residual expectation:[ParcoaExpectation expectationWithRemaining:residual expected:expected children:expectations]];
}

+ (ParcoaResult *)failWithRemaining:(NSString *)remaining expected:(NSString *)expected {
    return [[ParcoaResult alloc] initFail:[ParcoaExpectation expectationWithRemaining:remaining expected:expected children:nil]];
}

+ (ParcoaResult *)failWithRemaining:(NSString *)remaining expectedWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *expected = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [ParcoaResult failWithRemaining:remaining expected:expected];
}

+ (ParcoaResult *)failWithChildren:(NSArray *)children remaining:(NSString *)remaining expected:(NSString *)expected {
    NSArray *expectations = [children valueForKey:@"expectation"];
    return [[ParcoaResult alloc] initFail:[ParcoaExpectation expectationWithRemaining:remaining expected:expected children:expectations]];
}

- (ParcoaResult *)prependExpectationWithRemaining:(NSString *)remaining expected:(NSString *)expected {
    return [[ParcoaResult alloc] initFail:[ParcoaExpectation expectationWithRemaining:remaining expected:expected children:@[self.expectation]]];
}

- (ParcoaResult *)prependExpectationWithRemaining:(NSString *)remaining expectedWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *expected = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [self prependExpectationWithRemaining:remaining expected:expected];
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
        return [NSString stringWithFormat:@"ParcoaResult(Fail,%@)", self.expectation];
    }
}

#pragma mark - Traceback Generation

- (NSString *)traceback:(NSString *)input {
    return [self traceback:input full:YES];
}

- (NSString *)traceback:(NSString *)input full:(BOOL)full {
    return [self reduceTraceback:input expectation:self.expectation indent:0 full:full];
}

- (NSString *)reduceTraceback:(NSString *)input expectation:(ParcoaExpectation *)expectation indent:(NSUInteger)indent full:(BOOL)full{
    NSMutableString *tb = [NSMutableString stringWithString:[self formatTraceback:input expectation:expectation indent:indent]];
    
    if (full) {
        [expectation.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [tb appendString:[self reduceTraceback:input expectation:obj indent:indent+1 full:YES]];
        }];
    } else {
        if (expectation.children) {
            NSUInteger minCharactersRemaining = [[expectation.children valueForKeyPath:@"@min.minCharactersRemaining"] integerValue];
            NSUInteger bestChildIndex = [expectation.children indexOfObjectPassingTest:^BOOL(ParcoaExpectation *obj, NSUInteger idx, BOOL *stop) {
                return obj.minCharactersRemaining == minCharactersRemaining;
            }];
            [tb appendString:[self reduceTraceback:input expectation:expectation.children[bestChildIndex] indent:indent+1 full:NO]];
        }
    }
    return tb;
}

- (NSString *)formatTraceback:(NSString *)input expectation:(ParcoaExpectation *)expectation indent:(NSUInteger)indent {
    ParcoaLineColumn position = [input lineAndColumnForIndex:input.length - expectation.charactersRemaining];
    NSString *tabs = [@"" stringByPaddingToLength:indent withString:@"\t" startingAtIndex:0];
    return [NSString stringWithFormat:@"%@Line %u Column %u: %@\n", tabs, position.line, position.column, expectation.expected];
}

@end
