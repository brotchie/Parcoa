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

#import "Parcoa.h"

@implementation Parcoa

+ (ParcoaResult *)runParserWithTraceback:(ParcoaParser)parser input:(NSString *)input {
    ParcoaResult *result = parser(input);
    if (result.isFail) {
        NSLog(@"%@", [result traceback:input]);
    }
    return result;
}

+ (ParcoaParser)annotate:(ParcoaParser)parser expected:(NSString *)expected {
    return ^ParcoaResult *(NSString *input) {
        ParcoaResult *result = parser(input);
        if (result.isOK) {
            return result;
        } else {
            return [ParcoaResult failWithRemaining:input expected:expected];
        }
    };
}

+ (ParcoaParser)annotate:(ParcoaParser)parser expectedWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *expected = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [Parcoa annotate:parser expected:expected];
}

+ (ParcoaParser)unicharLiteral:(unichar)c {
    return [Parcoa annotate:[Parcoa takeOnce:[Parcoa isUnichar:c]]
       expectedWithFormat:@"Expected character '%c'", c];
}

+ (ParcoaParser)literal:(NSString *)c {
    return ^ParcoaResult *(NSString *input) {
        if ([input hasPrefix:c]) {
            return [ParcoaResult ok:c residual:[input substringFromIndex:c.length]];
        } else {
            return [ParcoaResult failWithRemaining:input expectedWithFormat:@"Expected string literal \"%@\"", c];
        }
    };
}

+ (ParcoaParser)peek:(NSString *)c {
    return ^ParcoaResult *(NSString *input) {
        if ([input hasPrefix:c]) {
            return [ParcoaResult ok:c residual:input];
        } else {
            return [ParcoaResult failWithRemaining:input expectedWithFormat:@"Expected peeked string \"%@\"", c];
        }
    };
}

+ (ParcoaParser)take:(NSUInteger)n {
    return ^ParcoaResult *(NSString *input) {
        if (input.length >= n) {
            return [ParcoaResult ok:[input substringToIndex:n] residual:[input substringFromIndex:n]];
        } else {
            return [ParcoaResult failWithRemaining:input expectedWithFormat:@"Expected string of length %d", n];
        }
    };
}

+ (ParcoaParser)takeOnce:(ParcoaUnicharPredicate)condition {
    return ^ParcoaResult *(NSString *input) {
        if (input.length && condition([input characterAtIndex:0])) {
            return [ParcoaResult ok:[input substringToIndex:1] residual:[input substringFromIndex:1]];
        } else {
            return [ParcoaResult failWithRemaining:input expected:@"Expected character matching predicate"];
        }
    };
}

+ (ParcoaParser)takeWhile:(ParcoaUnicharPredicate)condition {
    return ^ParcoaResult *(NSString *input) {
        NSUInteger i;
        for (i = 0; i < input.length; i++) {
            if (!condition([input characterAtIndex:i]))
                break;
        }
        return [ParcoaResult ok:[input substringToIndex:i] residual:[input substringFromIndex:i]];
    };
}

+ (ParcoaParser)takeWhile1:(ParcoaUnicharPredicate)condition {
    return ^ParcoaResult *(NSString *input) {
        ParcoaResult *result = [Parcoa takeWhile:condition](input);
        if ([result.value length] > 0) {
            return result;
        } else {
            return [ParcoaResult failWithRemaining:input expected:@"Expected at least one character matching predicate"];
        }
    };
}

+ (ParcoaParser)takeWhileInCharacterSet:(NSCharacterSet *)set {
    return [Parcoa takeWhile:[Parcoa inCharacterSet:set]];
}

+ (ParcoaParser)takeWhile1InCharacterSet:(NSCharacterSet *)set {
    return [Parcoa annotate:[Parcoa takeWhile1:[Parcoa inCharacterSet:set]]
       expectedWithFormat:@"Expected one or more characters in set.", set];
}

+ (ParcoaParser)takeWhileInClass:(NSString *)unichars {
    return [Parcoa takeWhile:[Parcoa inClass:unichars]];
}

+ (ParcoaParser)takeWhile1InClass:(NSString *)unichars {
    return [Parcoa takeWhile1:[Parcoa inClass:unichars]];
}

+ (ParcoaParser)takeUntil:(ParcoaUnicharPredicate)condition {
    return ^ParcoaResult *(NSString *input) {
        NSUInteger i;
        for (i = 0; i < input.length; i++) {
            if (condition([input characterAtIndex:i]))
                break;
        }
        return [ParcoaResult ok:[input substringToIndex:i] residual:[input substringFromIndex:i]];
    };
}

+ (ParcoaParser)skipSpace {
    return ^ParcoaResult *(NSString *input) {
        ParcoaResult *result = [Parcoa takeWhileInCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]](input);
        return [ParcoaResult ok:[NSNull null] residual:(result.isOK) ? result.residual : input];
    };
}

+ (ParcoaParser)atEnd {
    return ^ParcoaResult *(NSString *input) {
        return [ParcoaResult ok:[NSNumber numberWithBool:input.length == 0] residual:input];
    };
}

+ (ParcoaParser)endOfInput {
    return ^ParcoaResult *(NSString *input) {
        if (input.length == 0) {
            return [ParcoaResult ok:[NSNull null] residual:input];
        } else {
            return [ParcoaResult failWithRemaining:input expected:@"Expected end of input"];
        }
    };
}

#pragma mark - Predicates

+ (ParcoaUnicharPredicate)isUnichar:(unichar)c {
    return ^BOOL (unichar x) {
        return x == c;
    };
}

+ (ParcoaUnicharPredicate)inCharacterSet:(NSCharacterSet *)set {
    return ^BOOL (unichar x) {
        return [set characterIsMember:x];
    };
}

+ (ParcoaUnicharPredicate)inClass:(NSString *)unichars {
    return [Parcoa inCharacterSet:[NSCharacterSet characterSetWithCharactersInString:unichars]];
}

@end
