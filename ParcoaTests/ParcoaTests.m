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

- (void)testParcoaUnichar
{
    ParcoaParser unichar = [Parcoa unicharLiteral:'a'];
    ParcoaResult *ok = unichar(@"ab");
    ParcoaResult *fail = unichar(@"bb");
    STAssertTrue(ok.isOK, @"ab should match.");
    STAssertTrue(fail.isFail, @"bb shouldn't match");
    STAssertEqualObjects(ok.residual, @"b", @"Residual should be b.");
}

- (void)testParcoaString
{
    ParcoaParser hello = [Parcoa literal:@"hello"];
    ParcoaResult *ok = hello(@"hello world");
    ParcoaResult *fail = hello(@"nothing");
    STAssertTrue(ok.isOK, @"hello world should match.");
    STAssertTrue(fail.isFail, @"nothing shouldn't match.");
}

- (void)testParcoaChoice
{
    ParcoaParser or = [Parcoa choice:@[
                       [Parcoa literal:@"hello"],
                       [Parcoa literal:@"world"]]];
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
    ParcoaParser count = [Parcoa count:[Parcoa literal:@"Hello"] n:3];
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
    ParcoaParser many = [Parcoa many:[Parcoa literal:@"Hello"]];
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
    ParcoaParser many1 = [Parcoa many1:[Parcoa literal:@"Hello"]];
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
                               [Parcoa literal:@"Hello"],
                               [Parcoa literal:@"World"]]];
    ParcoaResult *ok = sequential(@"HelloWorld");
    ParcoaResult *fail = sequential(@"Hello World");
    STAssertTrue(ok.isOK, @"HelloWorld should match.");
    STAssertTrue(fail.isFail, @"Hello World shouldn't match.");
    
    STAssertTrue([ok.value count] == 2, @"Result count should be 2.");
}

- (void)testParcoaSequentialKeepLeftMost
{
    ParcoaParser sequentialLeft = [Parcoa sequentialKeepLeftMost:@[
                                   [Parcoa literal:@"A"],
                                   [Parcoa literal:@"B"],
                                   [Parcoa literal:@"C"]]];
    ParcoaResult *ok = sequentialLeft(@"ABC");
    STAssertTrue(ok.isOK, @"ABC should match.");
    STAssertEqualObjects(ok.value, @"A", @"Result should be left most match A.");
}

- (void)testParcoaSequentialKeepRightMost
{
    ParcoaParser sequentialRight = [Parcoa sequentialKeepRightMost:@[
                                   [Parcoa literal:@"A"],
                                   [Parcoa literal:@"B"],
                                   [Parcoa literal:@"C"]]];
    ParcoaResult *ok = sequentialRight(@"ABC");
    STAssertTrue(ok.isOK, @"ABC should match.");
    STAssertEqualObjects(ok.value, @"C", @"Result should be left most match C.");
}

- (void)testParcoaSepBy
{
    ParcoaParser sepBy = [Parcoa sepBy:[Parcoa literal:@"Hello"] delimiter:[Parcoa literal:@","]];
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
    ParcoaParser sepBy1 = [Parcoa sepBy1:[Parcoa literal:@"Hello"] delimiter:[Parcoa literal:@","]];
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
