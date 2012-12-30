//
//  ParcoaResult.m
//  Parcoa
//
//  Created by James Brotchie on 30/12/12.
//  Copyright (c) 2012 Factorial Products Pty. Ltd. All rights reserved.
//

#import "ParcoaResult.h"

@implementation ParcoaResult

@synthesize type = _type;
@synthesize reason = _reason;
@synthesize value = _value;
@synthesize residual = _residual;

- (id)initOK:(id)value residual:(NSString *)residual{
    self = [super init];
    if (self) {
        _type = ParcoaResultOK;
        _reason = nil;
        _value = value;
        _residual = residual;
    }
    return self;
}

- (id)initFail:(NSString *)reason {
    self = [super init];
    if (self) {
        _type = ParcoaResultFail;
        _reason = reason;
        _value = nil;
        _residual = nil;
    }
    return self;
}

+ (ParcoaResult *)ok:(id)value residual:(NSString *)residual{
    return [[ParcoaResult alloc] initOK:value residual:residual];
}

+ (ParcoaResult *)fail:(NSString *)reason {
    return [[ParcoaResult alloc] initFail:reason];
}

+ (ParcoaResult *)failWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *reason = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [ParcoaResult fail:reason];
}

- (BOOL)isFail {
    return _type == ParcoaResultFail;
}

- (BOOL)isOK {
    return _type == ParcoaResultOK;
}

- (void)clearResidual {
    _residual = nil;
}

- (NSString *)description {
    if ([self isOK]) {
        return [NSString stringWithFormat:@"ParcoaResult(OK,%@,%@)", self.value, self.residual];
    } else {
        return [NSString stringWithFormat:@"ParcoaResult(Fail,%@)", self.reason];
    }
}
@end
