//
//  ParcoaResult.h
//  Parcoa
//
//  Created by James Brotchie on 30/12/12.
//  Copyright (c) 2012 Factorial Products Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ParcoaResultFail,
    ParcoaResultOK
} ParcoaResultType;

@interface ParcoaResult : NSObject
@property (readonly) ParcoaResultType type;
@property (readonly) NSString *reason;
@property (readonly) NSString *residual;
@property (readonly) id value;

- (id)initOK:(id)value residual:(NSString *)residual;
- (id)initFail:(NSString *)reason;

- (BOOL)isFail;
- (BOOL)isOK;
- (void)clearResidual;

+ (ParcoaResult *)fail:(NSString *)reason;
+ (ParcoaResult *)failWithFormat:(NSString *)format, ...;
+ (ParcoaResult *)ok:(id)value residual:(NSString *)residual;

@end
