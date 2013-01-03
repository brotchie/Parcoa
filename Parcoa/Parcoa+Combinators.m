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

#import "Parcoa+Combinators.h"

@implementation Parcoa (Combinators)

+ (ParcoaParser)sequential:(NSArray *)parsers {
    return ^ParcoaResult *(NSString *input) {
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:parsers.count];
        NSString *residual = input;
        for (NSUInteger i = 0; i < parsers.count; i++) {
            ParcoaParser parser = [parsers objectAtIndex:i];
            ParcoaResult *result = parser(residual);
            if (result.isOK) {
                residual = result.residual;
                [values setObject:result.value atIndexedSubscript:i];
            } else {
                return [result prependContextWithRemaining:input expected:@"Expected element in sequence."];
            }
        }
        return [ParcoaResult ok:values residual:residual];
    };
}

+ (ParcoaParser)sequential:(NSArray *)parsers keepIndex:(NSInteger)n {
    return ^ParcoaResult *(NSString *input) {
        ParcoaResult *result = [Parcoa sequential:parsers](input);
        if (result.isOK) {
            NSUInteger index = (n >= 0) ? n : parsers.count + n;
            return [ParcoaResult ok:[result.value objectAtIndex:index] residual:result.residual];
        } else {
            return result;
        }
    };
}

+ (ParcoaParser)sequentialKeepLeftMost:(NSArray *)parsers {
    return [Parcoa sequential:parsers keepIndex:0];
}

+ (ParcoaParser)sequentialKeepRightMost:(NSArray *)parsers {
    return [Parcoa sequential:parsers keepIndex:-1];
}

+ (ParcoaParser)choice:(NSArray *)parsers {
    return ^ParcoaResult *(NSString *input) {
        NSMutableArray *failures = [NSMutableArray array];
        ParcoaResult *result = nil;
        for (NSUInteger i = 0; i < parsers.count; i++) {
            ParcoaParser parser = [parsers objectAtIndex:i];
            result = parser(input);
            if (result.isOK) {
                return result;
            } else {
                [failures addObject:result];
            }
        }
        return [ParcoaResult failWithFailures:failures remaining:input expected:@"Expected at least one match."];
    };
}

+ (ParcoaParser)count:(ParcoaParser)parser n:(NSUInteger)n {
    return ^ParcoaResult *(NSString *input) {
        NSMutableArray *values = [NSMutableArray array];
        NSString *residual = input;
        for (NSUInteger i = 0; i < n; i++) {
            ParcoaResult *result = parser(residual);
            if (result.isOK) {
                residual = result.residual;
                [values setObject:result.value atIndexedSubscript:i];
            } else {
                return [result prependContextWithRemaining:input expectedWithFormat:@"Expected %d repeats.", n];
            }
        }
        return [ParcoaResult ok:values residual:residual];
    };
}

+ (ParcoaParser)option:(ParcoaParser)parser default:(id)value {
    return ^ParcoaResult *(NSString *input) {
        ParcoaResult *result = parser(input);
        if (result.isOK) {
            return result;
        } else {
            return [ParcoaResult ok:value residual:input];
        }
    };
}

+ (ParcoaParser)optional:(ParcoaParser)parser {
    return [Parcoa option:parser default:[NSNull null]];
}

+ (ParcoaParser)notFollowedBy:(ParcoaParser)parser mustFail:(ParcoaParser)mustFail {
    return ^ParcoaResult *(NSString *input) {
        ParcoaResult *result = parser(input);
        
        // Don't need to consider the must fail parser if
        // the primary parser fails.
        if (result.isFail) {
            return result;
        }
        
        ParcoaResult *mustFailResult = mustFail(result.residual);
        if (mustFailResult.isFail) {
            return result;
        } else {
            // Both parsers OK, this fails the combinator.
            return [ParcoaResult failWithRemaining:input expected:@"Expected following parser to fail."];
        }
        
    };
}

+ (ParcoaParser)many:(ParcoaParser)parser {
    return ^ParcoaResult *(NSString *input) {
        NSMutableArray *values = [NSMutableArray array];
        NSString *residual = input;
        ParcoaResult *result = parser(residual);
        while (result.isOK) {
            [values addObject:result.value];
            residual = result.residual;
            result = parser(residual);
        }
        return [ParcoaResult ok:values residual:residual];
    };
}

+ (ParcoaParser)many1:(ParcoaParser)parser {
    return ^ParcoaResult *(NSString *input) {
        NSMutableArray *values = [NSMutableArray array];
        NSString *residual = input;
        ParcoaResult *result = parser(residual);
        while (result.isOK) {
            [values addObject:result.value];
            residual = result.residual;
            result = parser(residual);
        }
        if (values.count > 0) {
            return [ParcoaResult ok:values residual:residual];
        } else {
            return [result prependContextWithRemaining:input expected:@"Expected one or more times."];
        }
    };
}

+ (ParcoaParser)sepBy:(ParcoaParser)parser delimiter:(ParcoaParser)delimiter {
    return ^ParcoaResult *(NSString *input) {
        ParcoaResult *many = [Parcoa many:[Parcoa sequentialKeepLeftMost:@[
                                           parser,
                                           delimiter]]](input);
        ParcoaResult *last = parser(many.residual);
        if ([many.value count] > 0 && last.isFail) {
            return [last prependContextWithRemaining:input expected:@"Expected terminal value in list."];
        } else if (last.isFail) {
            return [ParcoaResult ok:@[] residual:input];
        } else {
            return [ParcoaResult ok:[many.value arrayByAddingObject:last.value] residual:last.residual];
        }
    };
}

+ (ParcoaParser)sepBy1:(ParcoaParser)parser delimiter:(ParcoaParser)delimiter {
    return ^ParcoaResult *(NSString *input) {
        ParcoaResult *result = [Parcoa sepBy:parser delimiter:delimiter](input);
        if (result.isOK && [result.value count] == 0) {
            return [ParcoaResult failWithRemaining:input expected:@"Expected more than one value in list"];
        } else {
            return result;
        }
    };
}

+ (ParcoaParser)between:(ParcoaParser)left parser:(ParcoaParser)parser right:(ParcoaParser)right {
    return [Parcoa sequential:@[left, parser, right] keepIndex:1];
}

+ (ParcoaParser)transform:(ParcoaParser)parser by:(ParcoaValueTransform)transform {
    return ^ParcoaResult *(NSString *input) {
        ParcoaResult *result = parser(input);
        if (result.isOK) {
            return [ParcoaResult ok:transform(result.value) residual:result.residual];
        } else {
            return result;
        }
    };
}

+ (ParcoaParser)concat:(ParcoaParser)parser {
    return [Parcoa transform:parser by:^NSString *(NSArray *value) {
        return [value componentsJoinedByString:@""];
    }];
}

+ (ParcoaParser)concatMany:(ParcoaParser)parser {
    return [Parcoa concat:[Parcoa many:parser]];
}

+ (ParcoaParser)concatMany1:(ParcoaParser)parser {
    return [Parcoa concat:[Parcoa many1:parser]];
}

+ (ParcoaParser)skipSurroundingSpaces:(ParcoaParser)parser {
    return [Parcoa between:[Parcoa spaces] parser:parser right:[Parcoa spaces]];
}

@end
