//
//  Parcoa.h
//  Parcoa
//
//  Created by James Brotchie on 30/12/12.
//  Copyright (c) 2012 Factorial Products Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParcoaResult.h"

typedef ParcoaResult *(^ParcoaParser)(NSString *input);

@interface Parcoa : NSObject
+ (ParcoaParser)string:(NSString *)c;
+ (ParcoaParser)peekString:(NSString *)c;
+ (ParcoaParser)take:(NSUInteger)n;
+ (ParcoaParser)takeWhile:(BOOL(^)(unichar))condition;
+ (ParcoaParser)atEnd;
+ (ParcoaParser)endOfInput;
@end
