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

#import "Parcoa+Primitives.h"
#import "Parcoa+Predicates.h"
#import "ParcoaString.h"

@implementation Parcoa (Primitives)

+ (ParcoaParser *)satisfy:(ParcoaPredicate *)predicate {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(ParcoaString *input) {
        if (input.length && [predicate check:[input characterAtIndex:0]]) {
            NSString *value = [input substringToIndex:1].string;
            ParcoaString *residual = [input substringFromIndex:1];
            return [ParcoaResult ok:value residual:residual expected:[ParcoaExpectation unsatisfiable]];
        } else {
            return [ParcoaResult failWithRemaining:input expectedWithFormat:@"Character matching predicate %@", predicate.description];
        }
    } name:@"satisfy" summary:predicate.description];
}

+ (ParcoaParser *)unichar:(unichar)c {
    return [[Parcoa satisfy:[Parcoa isUnichar:c]] parserWithName:@"unichar" summaryWithFormat:@"'%c'", c];
}

+ (ParcoaParser *)string:(NSString *)string {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(ParcoaString *input) {
        if ([input hasPrefix:string]) {
            return [ParcoaResult ok:string residual:[input substringFromIndex:string.length] expected:[ParcoaExpectation unsatisfiable]];
        } else {
            return [ParcoaResult failWithRemaining:input expectedWithFormat:@"String literal \"%@\"", string];
        }
    } name:@"string" summaryWithFormat:@"\"%@\"", string];
}

+ (ParcoaParser *)peek:(NSString *)string {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(ParcoaString *input) {
        if ([input hasPrefix:string]) {
            return [ParcoaResult ok:string residual:input expected:[ParcoaExpectation unsatisfiable]];
        } else {
            return [ParcoaResult failWithRemaining:input expectedWithFormat:@"String literal \"%@\"", string];
        }
    } name:@"peek" summaryWithFormat:@"\"%@\"", string];
}

+ (ParcoaParser *)take:(NSUInteger)n {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(ParcoaString *input) {
        if (input.length >= n) {
            return [ParcoaResult ok:[input substringToIndex:n].string residual:[input substringFromIndex:n] expected:[ParcoaExpectation unsatisfiable]];
        } else {
            return [ParcoaResult failWithRemaining:input expectedWithFormat:@"%u unichars", n];
        }
    } name:@"take" summaryWithFormat:@"%u unichars", n];
}

+ (ParcoaParser *)take:(ParcoaPredicate *)predicate count:(NSUInteger)n {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(ParcoaString *input) {
        ParcoaResult *result = [[Parcoa takeWhile1:predicate] parse:input];
        if (result.isOK && [result.value length] >= n) {
            return [ParcoaResult ok:[input substringToIndex:n].string residual:[input substringFromIndex:n] expected:[ParcoaExpectation unsatisfiable]];
        } else {
            return [ParcoaResult failWithRemaining:input expectedWithFormat:@"%u characters matching %@", n, predicate];
        }
    } name:@"takeCount" summaryWithFormat:@"%u characters matching %@", n, predicate];
}

+ (ParcoaParser *)oneOf:(NSString *)set {
    return [Parcoa satisfy:[Parcoa inClass:set]];
}

+ (ParcoaParser *)noneOf:(NSString *)set {
    return [Parcoa satisfy:[Parcoa not:[Parcoa inClass:set]]];
}

+ (ParcoaParser *)takeWhile:(ParcoaPredicate *)condition {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(ParcoaString *input) {
        NSUInteger i;
        for (i = 0; i < input.length; i++) {
            if (![condition check:[input characterAtIndex:i]])
                break;
        }
        NSString *value = [input substringToIndex:i].string;
        ParcoaString *residual = [input substringFromIndex:i];
        return [ParcoaResult ok:value residual:residual expectedWithFormat:@"Character matching predicate %@", condition.description];
    } name:@"takeWhile" summary:condition.description];
}

+ (ParcoaParser *)takeWhile1:(ParcoaPredicate *)condition {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(ParcoaString *input) {
        ParcoaResult *head = [[Parcoa satisfy:condition] parse:input];
        if (head.isOK) {
            ParcoaResult *tail = [[Parcoa takeWhile:condition] parse:head.residual];
            id value = [head.value stringByAppendingString:tail.value];
            return [ParcoaResult ok:value residual:tail.residual expectedWithFormat:@"Character matching predicate %@", condition.description];
        } else {
            return [ParcoaResult failWithRemaining:input expectedWithFormat:@"Character matching predicate %@", condition.description];
        }
    } name:@"takeWhile1" summary:condition.description];
}

+ (ParcoaParser *)takeUntil:(ParcoaPredicate *)condition {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(ParcoaString *input) {
        NSUInteger i;
        for (i = 0; i < input.length; i++) {
            if ([condition check:[input characterAtIndex:i]])
                break;
        }
        NSString *value = [input substringToIndex:i].string;
        ParcoaString *residual = [input substringFromIndex:i];
        return [ParcoaResult ok:value residual:residual expectedWithFormat:@"Character not matching predicate %@", condition.description];
    } name:@"takeUntil" summary:condition.description];
}

+ (ParcoaParser *)atEnd {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(ParcoaString *input) {
        return [ParcoaResult ok:[NSNumber numberWithBool:input.length == 0] residual:input expected:[ParcoaExpectation unsatisfiable]];
    } name:@"atEnd" summary:nil];
}

+ (ParcoaParser *)endOfInput {
    return [ParcoaParser parserWithBlock:^ParcoaResult *(ParcoaString *input) {
        if (input.length == 0) {
            return [ParcoaResult ok:[NSNull null] residual:input expected:[ParcoaExpectation unsatisfiable]];
        } else {
            return [ParcoaResult failWithRemaining:input expected:@"Expected end of input"];
        }
    } name:@"endOfInput" summary:nil];
}

+ (ParcoaParser *)spaces {
    return [Parcoa takeWhile:[Parcoa isSpace]];
}

+ (ParcoaParser *)space {
    return [Parcoa satisfy:[Parcoa isSpace]];
}

+ (ParcoaParser *)newline {
    return [Parcoa unichar:'\n'];
}

+ (ParcoaParser *)tab {
    return [Parcoa unichar:'\t'];
}

+ (ParcoaParser *)upper {
    return [Parcoa satisfy:[Parcoa inCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet] setName:@"uppercase"]];
}

+ (ParcoaParser *)lower {
    return [Parcoa satisfy:[Parcoa inCharacterSet:[NSCharacterSet lowercaseLetterCharacterSet] setName:@"lowercase"]];
}

+ (ParcoaParser *)alphaNum {
    return [Parcoa satisfy:[Parcoa inCharacterSet:[NSCharacterSet alphanumericCharacterSet] setName:@"alphanumeric"]];
}

+ (ParcoaParser *)digit {
    return [Parcoa satisfy:[Parcoa inCharacterSet:[NSCharacterSet decimalDigitCharacterSet] setName:@"digit"]];
}

+ (ParcoaParser *)letter {
    return [Parcoa satisfy:[Parcoa inCharacterSet:[NSCharacterSet letterCharacterSet] setName:@"letter"]];
}

+ (ParcoaParser *)hexDigit {
    return [[Parcoa oneOf:@"0123456789ABCDEFabcdef"] parserWithName:@"hexDigit" summary:nil];
}

+ (ParcoaParser *)anyUnichar {
    return [[Parcoa take:1] parserWithName:@"anyUnichar" summary:nil];
}

@end
