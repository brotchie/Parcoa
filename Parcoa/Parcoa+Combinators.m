//
//  Parcoa+Combinators.m
//  Parcoa
//
//  Created by James Brotchie on 30/12/12.
//  Copyright (c) 2012 Factorial Products Pty. Ltd. All rights reserved.
//

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
                return [ParcoaResult failWithFormat:@"Parser %d in sequence failed -> %@", i, result.reason];
            }
        }
        return [ParcoaResult ok:values residual:residual];
    };
}

+ (ParcoaParser)sequentialKeepLeftMost:(NSArray *)parsers {
    return ^ParcoaResult *(NSString *input) {
        ParcoaResult *result = [Parcoa sequential:parsers](input);
        if (result.isOK) {
            return [ParcoaResult ok:[result.value objectAtIndex:0] residual:result.residual];
        } else {
            return result;
        }
    };
}

+ (ParcoaParser)sequentialKeepRightMost:(NSArray *)parsers {
    return ^ParcoaResult *(NSString *input) {
        ParcoaResult *result = [Parcoa sequential:parsers](input);
        if (result.isOK) {
            return [ParcoaResult ok:[result.value lastObject] residual:result.residual];
        } else {
            return result;
        }
    };
}

+ (ParcoaParser)choice:(NSArray *)parsers {
    return ^ParcoaResult *(NSString *input) {
        ParcoaResult *result = nil;
        for (NSUInteger i = 0; i < parsers.count; i++) {
            ParcoaParser parser = [parsers objectAtIndex:i];
            result = parser(input);
            if (result.isOK)
                break;
        }
        return result;
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
                return [ParcoaResult fail:@"Count failed."];
            }
        }
        return [ParcoaResult ok:values residual:residual];
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
        ParcoaResult *result = [Parcoa many:parser](input);
        if ([result.value count] > 0) {
            return result;
        } else {
            return [ParcoaResult fail:@"Less than one result."];
        }
    };
}

/*+ (ParcoaParser)zeroOrOne:(ParcoaParser)parser {
    return ^ParcoaResult *(NSString *input) {
        ParcoaResult *result = [Parcoa many:parser](input);
        if ([result.value] <= 1) {
            return result;
        } else {
            return [ParcoaResult failWithFormat:@"More than one result -> %@", result];
        }
    };
}*/

+ (ParcoaParser)sepBy:(ParcoaParser)parser delimiter:(ParcoaParser)delimiter {
    return ^ParcoaResult *(NSString *input) {
        ParcoaResult *many = [Parcoa many:[Parcoa sequentialKeepLeftMost:@[
                                           parser,
                                           delimiter]]](input);
        ParcoaResult *last = parser(many.residual);
        if ([many.value count] > 0 && last.isFail) {
            return [ParcoaResult fail:@"Missing final value."];
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
            return [ParcoaResult fail:@"Less than one result."];
        } else {
            return result;
        }
    };
}
@end
