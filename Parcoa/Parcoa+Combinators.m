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
#import "Parcoa+Primitives.h"

@implementation Parcoa (Combinators)

+ (ParcoaParser *)choice:(NSArray *)parsers {
    NSString *summary = [[parsers valueForKeyPath:@"description"] componentsJoinedByString:@", "];
    
    return [ParcoaParser parserWithBlock:^ParcoaResult *(NSString *input) {
        NSMutableArray *failures = [NSMutableArray array];
        for (NSUInteger i = 0; i < parsers.count; i++) {
            
            ParcoaParser *parser = parsers[i];
            ParcoaResult *result = [parser parse:input];
            
            if (result.isOK) {
                return [ParcoaResult okWithChildren:failures value:result.value residual:result.residual expected:[ParcoaExpectation choice]];
            } else {
                [failures addObject:result];
            }
        }
        return [ParcoaResult failWithChildren:failures remaining:input expected:@"one or more matches"];

    } name:@"choice" summary:summary];
}

+ (ParcoaParser *)parser:(ParcoaParser *)parser or:(ParcoaParser *)right {
    return [Parcoa choice:@[parser, right]];
}

+ (ParcoaParser *)count:(ParcoaParser *)parser n:(NSUInteger)n {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(NSString *input) {
        NSMutableArray *values = [NSMutableArray array];
        NSString *residual = input;
        
        for (NSUInteger i = 0; i < n; i++) {
            ParcoaResult *result = [parser parse:residual];
            if (result.isOK) {
                residual = result.residual;
                [values setObject:result.value atIndexedSubscript:i];
            } else {
                return [result prependExpectationWithRemaining:input expectedWithFormat:@"%u repeats", n];
            }
        }
        return [ParcoaResult ok:values residual:residual expected:[ParcoaExpectation unsatisfiable]];
    } name:@"count" summaryWithFormat:@"%u, %@", n, parser.description];
}

+ (ParcoaParser *)option:(ParcoaParser *)parser default:(id)value {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(NSString *input) {
        ParcoaResult *result = [parser parse:input];
        if (result.isOK) {
            return result;
        } else {
            return [ParcoaResult okWithChildren:@[result] value:value residual:input expected:@"optional child parser matched"];
        }
    } name:@"option" summaryWithFormat:@"%@, %@", value, parser];
}

+ (ParcoaParser *)optional:(ParcoaParser *)parser {
    return [Parcoa option:parser default:[NSNull null]];
}

+ (ParcoaParser *)parser:(ParcoaParser *)parser notFollowedBy:(ParcoaParser *)following {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(NSString *input) {
        ParcoaResult *result = [parser parse:input];
        
        // Don't need to consider the must fail parser if
        // the primary parser fails.
        if (result.isFail) {
            return result;
        }
        
        ParcoaResult *mustFailResult = [following parse:result.residual];
        if (mustFailResult.isFail) {
            return result;
        } else {
            // Both parsers OK, this fails the combinator.
            return [ParcoaResult failWithRemaining:input expected:@"followed by parser to fail"];
        }
    } name:@"notFollowedBy" summaryWithFormat:@"%@, not %@", parser, following];
}

+ (ParcoaParser *)many:(ParcoaParser *)parser {
    return [Parcoa option:[Parcoa many1:parser] default:@[]];
}

+ (ParcoaParser *)many1:(ParcoaParser *)parser {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(NSString *input) {
        NSMutableArray *values = [NSMutableArray array];
        NSMutableArray *results = [NSMutableArray array];
        
        NSString *residual = input;
        ParcoaResult *result = [parser parse:residual];
        
        while (result.isOK) {
            [results addObject:result];
            [values addObject:result.value];
            residual = result.residual;
            result = [parser parse:residual];
        }
        [results addObject:result];
        if (values.count > 0) {
            return [ParcoaResult okWithChildren:results value:values residual:residual expected:@"more matches of child parser"];
        } else {
            return [result prependExpectationWithRemaining:input expected:@"one or more matches of child parser"];
        }
    } name:@"many1" summary:parser.description];
}

+ (ParcoaParser *)sepBy:(ParcoaParser *)parser delimiter:(ParcoaParser *)delimiter {
    return [[Parcoa option:[Parcoa sepBy1:parser delimiter:delimiter] default:@[]] parserWithName:@"sepBy" summaryWithFormat:@"%@, %@", parser, delimiter];
}

+ (ParcoaParser *)sepBy1:(ParcoaParser *)parser delimiter:(ParcoaParser *)delimiter {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(NSString *input) {
        ParcoaResult *result = [[Parcoa sequential:@[parser, [Parcoa many:[Parcoa parser:delimiter keepRight:parser]]]] parse:input];
        if (result.isOK) {
            id value = [@[result.value[0]] arrayByAddingObjectsFromArray:result.value[1]];
            return [ParcoaResult okWithChildren:@[result] value:value residual:result.residual expected:@"more matches of delimiter and child parser"];
        } else {
            return [result prependExpectationWithRemaining:input expected:@"one or more separated items"];
        }
    } name:@"sepBy1" summaryWithFormat:@"%@, %@", parser, delimiter];
}

+ (ParcoaParser *)sepByKeep:(ParcoaParser *)parser delimiter:(ParcoaParser *)delimiter {
    return [[Parcoa option:[Parcoa sepBy1Keep:parser delimiter:delimiter] default:@[]] parserWithName:@"sepByKeep" summaryWithFormat:@"%@, %@", parser, delimiter];
}

+ (ParcoaParser *)sepBy1Keep:(ParcoaParser *)parser delimiter:(ParcoaParser *)delimiter {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(NSString *input) {
        ParcoaResult *result = [[Parcoa sequential:@[parser, [Parcoa many:[Parcoa sequential:@[delimiter, parser]]]]] parse:input];
        if (result.isOK) {
            NSMutableArray *value = [NSMutableArray arrayWithObject:result.value[0]];
            [result.value[1] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [value addObjectsFromArray:obj];
            }];
            return [ParcoaResult okWithChildren:@[result] value:value residual:result.residual expected:@"more matches of delimiter and child parser"];
        } else {
            return [result prependExpectationWithRemaining:input expected:@"one or more separated items"];
        }
    } name:@"sepBy1Keep" summaryWithFormat:@"%@, %@", parser, delimiter];
}

+ (ParcoaParser *)sequential:(NSArray *)parsers {
    NSString *summary = [[parsers valueForKeyPath:@"description"] componentsJoinedByString:@", "];
    return [ParcoaParser parserWithBlock:^ParcoaResult *(NSString *input) {
        NSMutableArray *values = [NSMutableArray array];
        NSMutableArray *results = [NSMutableArray array];
        NSString *residual = input;
        for (NSUInteger i = 0; i < parsers.count; i++) {
            ParcoaParser *parser = parsers[i];
            ParcoaResult *result = [parser parse:residual];
            [results addObject:result];
            
            if (result.isOK) {
                residual = result.residual;
                [values setObject:result.value atIndexedSubscript:i];
            } else {
                return [ParcoaResult failWithChildren:results remaining:input expected:@"all parsers in sequence to match"];
            }
        }
        return [ParcoaResult okWithChildren:results value:values residual:residual expected:[ParcoaExpectation unsatisfiable]];
    } name:@"sequential" summary:summary];
}

+ (ParcoaParser *)parser:(ParcoaParser *)parser then:(ParcoaParser *)right {
    return [Parcoa sequential:@[parser, right]];
}

+ (ParcoaParser *)parser:(ParcoaParser *)left keepLeft:(ParcoaParser *)right {
    return [Parcoa parser:[Parcoa sequential:@[left, right]] valueAtIndex:0];
}

+ (ParcoaParser *)parser:(ParcoaParser *)left keepRight:(ParcoaParser *)right {
    return [Parcoa parser:[Parcoa sequential:@[left, right]] valueAtIndex:1];
}

+ (ParcoaParser *)between:(ParcoaParser *)left parser:(ParcoaParser *)parser right:(ParcoaParser *)right {
    return [Parcoa parser:[Parcoa sequential:@[left, parser, right]] valueAtIndex:1];
}

+ (ParcoaParser *)parser:(ParcoaParser *)parser transform:(ParcoaValueTransform)transform name:(NSString *)name {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(NSString *input) {
        ParcoaResult *result = [parser parse:input];
        if (result.isOK) {
            return [ParcoaResult ok:transform(result.value) residual:result.residual expected:result.expectation.expected];
        } else {
            return result;
        }
    } name:@"transform" summary:name];
}

+ (ParcoaParser *)concat:(ParcoaParser *)parser {
    return [Parcoa parser:parser transform:^id(id value) {
        return [value componentsJoinedByString:@""];
    } name:@"concat"];
}

+ (ParcoaParser *)concatMany:(ParcoaParser *)parser {
    return [Parcoa concat:[Parcoa many:parser]];
}

+ (ParcoaParser *)concatMany1:(ParcoaParser *)parser {
    return [Parcoa concat:[Parcoa many1:parser]];
}

+ (ParcoaParser *)skipSurroundingSpaces:(ParcoaParser *)parser {
    return [Parcoa between:[Parcoa spaces] parser:parser right:[Parcoa spaces]];
}

+ (ParcoaParser *)parser:(ParcoaParser *)parser valueAtIndex:(NSUInteger)index {
    NSString *name = [NSString stringWithFormat:@"valueAtIndex(%u)", index];
    return [Parcoa parser:parser transform:^id(NSArray *value) {
        return value[index];
    } name:name];
}
@end
