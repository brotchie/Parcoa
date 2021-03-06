/*
   ____
  |  _ \ __ _ _ __ ___ ___   __ _   Parcoa - Objective-C Parser Combinators
  | |_) / _` | '__/ __/ _ \ / _` |
  |  __/ (_| | | | (_| (_) | (_| |  Copyright (c) 2012,2013 James Brotchie
  |_|   \__,_|_|  \___\___/ \__,_|  https://github.com/brotchie/Parcoa


  The MIT License
  
  Copyright (c) 2012,2013 James Brotchie
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

#define _Concat(A,B) A##B
#define STAssertParseOK(PARSER,INPUT) XCTAssertTrue([PARSER parse:INPUT].isOK, @"%@ should parse.", INPUT)
#define STAssertParseFail(PARSER,INPUT) XCTAssertTrue([PARSER parse:INPUT].isFail, @"%@ should fail.", INPUT)

@implementation ParcoaTests

- (void)testParcoaUnichar
{
    ParcoaParser *unichar = [Parcoa unichar:'a'];
    ParcoaResult *ok = [unichar parse:@"ab"];
    ParcoaResult *fail = [unichar parse:@"bb" ];
    XCTAssertTrue(ok.isOK, @"ab should match.");
    XCTAssertTrue(fail.isFail, @"bb shouldn't match");
    XCTAssertEqualObjects(ok.residual, @"b", @"Residual should be b.");
}

- (void)testParcoaString
{
    ParcoaParser *hello = [Parcoa string:@"hello"];
    ParcoaResult *ok = [hello parse:@"hello world"];
    ParcoaResult *fail = [hello parse:@"nothing"];
    XCTAssertTrue(ok.isOK, @"hello world should match.");
    XCTAssertTrue(fail.isFail, @"nothing shouldn't match.");
}

- (void)testParcoaChoice
{
    ParcoaParser *or = [Parcoa choice:@[
                       [Parcoa string:@"hello"],
                       [Parcoa string:@"world"]]];
    ParcoaResult *hello = [or parse:@"hello"];
    ParcoaResult *world = [or parse:@"world"];
    ParcoaResult *fail  = [or parse:@"nothing"];
    
    XCTAssertTrue(hello.isOK, @"hello should match.");
    XCTAssertTrue([hello.value isEqualToString:@"hello"], @"hello value should be hello.");
    XCTAssertTrue(world.isOK, @"world should match.");
    XCTAssertTrue([world.value isEqualToString:@"world"], @"world value should be world.");
    XCTAssertTrue(fail.isFail, @"nothing shouldn't match.");
}

- (void)testParcoaTake
{
    ParcoaParser *take = [Parcoa take:5];
    ParcoaResult *hello = [take parse:@"hello world"];
    ParcoaResult *fail = [take parse:@"hell"];
    
    XCTAssertTrue(hello.isOK, @"hello should match.");
    XCTAssertTrue([hello.value isEqualToString:@"hello"], @"hello value should be hello.");
    XCTAssertTrue(fail.isFail, @"fail should fail.");
}

- (void)testParcoaTakeCount
{
    ParcoaParser *take = [Parcoa take:[Parcoa isUnichar:'a'] count:4];
    STAssertParseOK(take, @"aaaa");
    STAssertParseOK(take, @"aaaaa");
    STAssertParseFail(take, @"aaa");
    STAssertParseFail(take, @"bbbb");
}

- (void)testParcoaTakeWhile
{
    ParcoaParser *takeWhile = [Parcoa takeWhile:[Parcoa isUnichar:'A']];

    ParcoaResult *many = [takeWhile parse:@"AAAABBBB"];
    ParcoaResult *none = [takeWhile parse:@"BBBB"];

    XCTAssertEqualObjects(many.value, @"AAAA", @"Value should be AAAA.");
    XCTAssertEqualObjects(none.value, @"", @"Value should be an empty string.");
}

- (void)testParcoaCount
{
    ParcoaParser *count = [Parcoa count:[Parcoa string:@"Hello"] n:3];
    ParcoaResult *ok = [count parse:@"HelloHelloHello"];
    ParcoaResult *fail = [count parse:@"HelloWorldHello"];
    
    XCTAssertTrue(ok.isOK, @"HelloHelloHello should match.");
    NSLog(@"%@", ok.value);
    XCTAssertTrue([ok.value count] == 3, @"Result should have three entries.");
    XCTAssertEqualObjects([ok.value objectAtIndex:0], @"Hello", @"Result should have Hello as entries.");
    XCTAssertTrue(fail.isFail, @"HelloWorldHello shouldn't match.");
}

- (void)testParcoaMany
{
    ParcoaParser *many = [Parcoa many:[Parcoa string:@"Hello"]];
    ParcoaResult *empty = [many parse:@""];
    ParcoaResult *ok0 = [many parse:@"World"];
    ParcoaResult *ok3 = [many parse:@"HelloHelloHello"];
    
    XCTAssertTrue(empty.isOK, @"Empty string should match.");
    XCTAssertTrue(ok0.isOK, @"World should match.");
    XCTAssertTrue([ok0.value count] == 0, @"World should have count 0.");
    XCTAssertTrue(ok3.isOK, @"HelloHelloHello should match.");
    XCTAssertTrue([ok3.value count] == 3, @"HelloHelloHello should have count 3.");
}

- (void)testParcoaMany1
{
    ParcoaParser *many1 = [Parcoa many1:[Parcoa string:@"Hello"]];
    ParcoaResult *empty = [many1 parse:@""];
    ParcoaResult *fail0 = [many1 parse:@"World"];
    ParcoaResult *ok3 = [many1 parse:@"HelloHelloHello"];
    
    XCTAssertTrue(empty.isFail, @"Empty string shouldn't match.");
    XCTAssertTrue(fail0.isFail, @"World shouldn't match.");
    XCTAssertTrue(ok3.isOK, @"HelloHelloHello should match.");
    XCTAssertTrue([ok3.value count] == 3, @"HelloHelloHello should have count 3.");
}

- (void)testParcoaSequential
{
    ParcoaParser *sequential = [Parcoa sequential:@[
                               [Parcoa string:@"Hello"],
                               [Parcoa string:@"World"]]];
    ParcoaResult *ok = [sequential parse:@"HelloWorld"];
    ParcoaResult *fail = [sequential parse:@"Hello World"];
    XCTAssertTrue(ok.isOK, @"HelloWorld should match.");
    XCTAssertTrue(fail.isFail, @"Hello World shouldn't match.");
    
    XCTAssertTrue([ok.value count] == 2, @"Result count should be 2.");
}


@end
