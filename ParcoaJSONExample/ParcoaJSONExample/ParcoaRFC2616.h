//
//  ParcoaRFC2616.h
//  ParcoaJSONExample
//
//  Created by James Brotchie on 1/01/13.
//  Copyright (c) 2013 Factorial Products Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parcoa.h"

@interface ParcoaRFC2616 : NSObject
+ (ParcoaParser)requestParser;
+ (ParcoaParser)responseParser;
@end
