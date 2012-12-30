//
//  ParcoaTests.m
//  ParcoaTests
//
//  Created by James Brotchie on 30/12/12.
//  Copyright (c) 2012 Factorial Products Pty. Ltd. All rights reserved.
//

#import "ParcoaTests.h"
#import "Parcoa.h"
#import "Parcoa+Combinators.h"

@implementation ParcoaTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testParcoaString
{
    ParcoaParser hello = [Parcoa string:@"hello"];
    ParcoaResult *ok = hello(@"hello world");
    ParcoaResult *fail = hello(@"nothing");
    STAssertTrue(ok.isOK, @"hello world should match.");
    STAssertTrue(fail.isFail, @"nothing shouldn't match.");
}

- (void)testParcoaChoice
{
    ParcoaParser or = [Parcoa choice:@[
                       [Parcoa string:@"hello"],
                       [Parcoa string:@"world"]]];
    ParcoaResult *hello = or(@"hello");
    ParcoaResult *world = or(@"world");
    ParcoaResult *fail  = or(@"nothing");
    
    STAssertTrue(hello.isOK, @"hello should match.");
    STAssertTrue([hello.value isEqualToString:@"hello"], @"hello value should be hello.");
    STAssertTrue(world.isOK, @"world should match.");
    STAssertTrue([world.value isEqualToString:@"world"], @"world value should be world.");
    STAssertTrue(fail.isFail, @"nothing shouldn't match.");
}

- (void)testParcoaTake
{
    ParcoaParser take = [Parcoa take:5];
    ParcoaResult *hello = take(@"hello world");
    ParcoaResult *fail = take(@"hell");
    
    STAssertTrue(hello.isOK, @"hello should match.");
    STAssertTrue([hello.value isEqualToString:@"hello"], @"hello value should be hello.");
    STAssertTrue(fail.isFail, @"fail should fail.");
}

- (void)testParcoaTakeWhile
{
    ParcoaParser takeWhile = [Parcoa takeWhile:^BOOL(unichar c) {
        return c == 'A';
    }];

    ParcoaResult *many = takeWhile(@"AAAABBBB");
    ParcoaResult *none = takeWhile(@"BBBB");

    STAssertEqualObjects(many.value, @"AAAA", @"Value should be AAAA.");
    STAssertEqualObjects(none.value, @"", @"Value should be an empty string.");
}

- (void)testParcoaCount
{
    ParcoaParser count = [Parcoa count:[Parcoa string:@"Hello"] n:3];
    ParcoaResult *ok = count(@"HelloHelloHello");
    ParcoaResult *fail = count(@"HelloWorldHello");
    
    STAssertTrue(ok.isOK, @"HelloHelloHello should match.");
    NSLog(@"%@", ok.value);
    STAssertTrue([ok.value count] == 3, @"Result should have three entries.");
    STAssertEqualObjects([ok.value objectAtIndex:0], @"Hello", @"Result should have Hello as entries.");
    STAssertTrue(fail.isFail, @"HelloWorldHello shouldn't match.");
}

- (void)testParcoaMany
{
    ParcoaParser many = [Parcoa many:[Parcoa string:@"Hello"]];
    ParcoaResult *empty = many(@"");
    ParcoaResult *ok0 = many(@"World");
    ParcoaResult *ok3 = many(@"HelloHelloHello");
    
    STAssertTrue(empty.isOK, @"Empty string should match.");
    STAssertTrue(ok0.isOK, @"World should match.");
    STAssertTrue([ok0.value count] == 0, @"World should have count 0.");
    STAssertTrue(ok3.isOK, @"HelloHelloHello should match.");
    STAssertTrue([ok3.value count] == 3, @"HelloHelloHello should have count 3.");
}

- (void)testParcoaMany1
{
    ParcoaParser many1 = [Parcoa many1:[Parcoa string:@"Hello"]];
    ParcoaResult *empty = many1(@"");
    ParcoaResult *fail0 = many1(@"World");
    ParcoaResult *ok3 = many1(@"HelloHelloHello");
    
    STAssertTrue(empty.isFail, @"Empty string shouldn't match.");
    STAssertTrue(fail0.isFail, @"World shouldn't match.");
    STAssertTrue(ok3.isOK, @"HelloHelloHello should match.");
    STAssertTrue([ok3.value count] == 3, @"HelloHelloHello should have count 3.");
}

- (void)testParcoaSequential
{
    ParcoaParser sequential = [Parcoa sequential:@[
                               [Parcoa string:@"Hello"],
                               [Parcoa string:@"World"]]];
    ParcoaResult *ok = sequential(@"HelloWorld");
    ParcoaResult *fail = sequential(@"Hello World");
    STAssertTrue(ok.isOK, @"HelloWorld should match.");
    STAssertTrue(fail.isFail, @"Hello World shouldn't match.");
    
    STAssertTrue([ok.value count] == 2, @"Result count should be 2.");
}

- (void)testParcoaSequentialKeepLeftMost
{
    ParcoaParser sequentialLeft = [Parcoa sequentialKeepLeftMost:@[
                                   [Parcoa string:@"A"],
                                   [Parcoa string:@"B"],
                                   [Parcoa string:@"C"]]];
    ParcoaResult *ok = sequentialLeft(@"ABC");
    STAssertTrue(ok.isOK, @"ABC should match.");
    STAssertEqualObjects(ok.value, @"A", @"Result should be left most match A.");
}

- (void)testParcoaSequentialKeepRightMost
{
    ParcoaParser sequentialRight = [Parcoa sequentialKeepRightMost:@[
                                   [Parcoa string:@"A"],
                                   [Parcoa string:@"B"],
                                   [Parcoa string:@"C"]]];
    ParcoaResult *ok = sequentialRight(@"ABC");
    STAssertTrue(ok.isOK, @"ABC should match.");
    STAssertEqualObjects(ok.value, @"C", @"Result should be left most match C.");
}

- (void)testParcoaSepBy
{
    ParcoaParser sepBy = [Parcoa sepBy:[Parcoa string:@"Hello"] delimiter:[Parcoa string:@","]];
    ParcoaResult *oknone = sepBy(@"");
    ParcoaResult *ok = sepBy(@"Hello,Hello,Hello");
    ParcoaResult *fail = sepBy(@"Hello,World,Hello");
    ParcoaResult *fail2 = sepBy(@"Hello,Hello,");
    
    STAssertTrue(oknone.isOK, @"Empty string should match.");
    STAssertTrue(ok.isOK, @"Hello,Hello,Hello should match.");
    STAssertTrue(fail.isFail, @"Hello,World,Hello shouldn't match.");
    STAssertTrue(fail2.isFail, @"Hello,Hello, shouldn't match,");
}

- (void)testParcoaSepBy1
{
    ParcoaParser sepBy1 = [Parcoa sepBy1:[Parcoa string:@"Hello"] delimiter:[Parcoa string:@","]];
    ParcoaResult *failnone = sepBy1(@"");
    ParcoaResult *ok = sepBy1(@"Hello,Hello,Hello");
    ParcoaResult *fail = sepBy1(@"Hello,World,Hello");
    ParcoaResult *fail2 = sepBy1(@"Hello,Hello,");
    
    STAssertTrue(failnone.isFail, @"Empty string shouldn't match.");
    STAssertTrue(ok.isOK, @"Hello,Hello,Hello should match.");
    STAssertTrue(fail.isFail, @"Hello,World,Hello shouldn't match.");
    STAssertTrue(fail2.isFail, @"Hello,Hello, shouldn't match,");
}

@end
