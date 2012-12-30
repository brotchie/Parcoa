//
//  Parcoa.m
//  Parcoa
//
//  Created by James Brotchie on 30/12/12.
//  Copyright (c) 2012 Factorial Products Pty. Ltd. All rights reserved.
//

#import "Parcoa.h"

@implementation Parcoa

+ (ParcoaParser)string:(NSString *)c {
    return ^ParcoaResult *(NSString *input) {
        if ([input hasPrefix:c]) {
            return [ParcoaResult ok:c residual:[input substringFromIndex:c.length]];
        } else {
            return [ParcoaResult fail:@"String not found."]; 
        }
    };
}

+ (ParcoaParser)peekString:(NSString *)c {
    return ^ParcoaResult *(NSString *input) {
        if ([input hasPrefix:c]) {
            return [ParcoaResult ok:c residual:input];
        } else {
            return [ParcoaResult fail:@"String not found."];
        }
    };
}



+ (ParcoaParser)take:(NSUInteger)n {
    return ^ParcoaResult *(NSString *input) {
        if (input.length < n) {
            return [ParcoaResult fail:@"Input string too short."];
        } else {
            return [ParcoaResult ok:[input substringToIndex:n] residual:[input substringFromIndex:n]];
        }
    };
}

+ (ParcoaParser)takeWhile:(BOOL (^)(unichar))condition {
    return ^ParcoaResult *(NSString *input) {
        NSUInteger i;
        for (i = 0; i < input.length; i++) {
            if (!condition([input characterAtIndex:i]))
                break;
        }
        return [ParcoaResult ok:[input substringToIndex:i] residual:[input substringFromIndex:i]];
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
            return [ParcoaResult ok:nil residual:input];
        } else {
            return [ParcoaResult fail:@"Not at end of input."];
        }
    };
}

@end
