//
//  main.m
//  ParcoaExamples
//
//  Created by James Brotchie on 4/01/13.
//  Copyright (c) 2013 Factorial Products Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Examples.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        [Examples jsonExample];
        [Examples rfc2616Example];
    }
    return 0;
}

