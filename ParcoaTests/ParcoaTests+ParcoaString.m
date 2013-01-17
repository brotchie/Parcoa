//
//  ParcoaTests+ParcoaString.m
//  Parcoa
//
//  Created by James Brotchie on 17/01/13.
//  Copyright (c) 2013 Factorial Products Pty. Ltd. All rights reserved.
//

#import "ParcoaTests+ParcoaString.h"
#import "ParcoaString.h"

@implementation ParcoaTests_ParcoaString

- (void)testHasPrefix {
    ParcoaString *s = [ParcoaString stringWithString:@"Hello World"];
    STAssertTrue([s hasPrefix:@"Hello"], @"Hello World has prefix Hello.");
    STAssertFalse([s hasPrefix:@"ello"], @"Hello World doesn't have prefix ello.");
}

- (void)testHasSuffix {
    ParcoaString *s = [ParcoaString stringWithString:@"Hello World"];
    STAssertTrue([s hasSuffix:@"World"], @"Hello World has suffix World.");
    STAssertFalse([s hasSuffix:@"Worl"], @"Hello World doesn't have suffix Worl.");
}

- (void)testCharacterAtIndex {
    ParcoaString *s = [ParcoaString stringWithString:@"Hello World"];
    
    STAssertTrue([s characterAtIndex:4] == 'o', @"Character at index 4 should be 'o'.");
    STAssertTrue([s characterAtIndex:10] == 'd', @"Character at index 10 should be 'd'.");
}

- (void)testSubstringToIndex {
    ParcoaString *s = [ParcoaString stringWithString:@"Hello World"];
    STAssertEqualObjects([s substringToIndex:5].string, @"Hello", @"Substring to 5 should be Hello.");
}
- (void)testSubstringFromIndex {
    ParcoaString *s = [ParcoaString stringWithString:@"Hello World"];
    STAssertEqualObjects([s substringFromIndex:6].string, @"World", @"Substring from 6 should be World.");
}

@end
