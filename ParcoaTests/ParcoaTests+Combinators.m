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

#import "ParcoaTests+Combinators.h"
#import "Parcoa.h"

@implementation ParcoaTests_Combinators

- (void)testParcoaNotFollowedBy {
    ParcoaParser *let = [Parcoa string:@"let"];
    ParcoaParser *alphanum = [Parcoa alphaNum];
    ParcoaParser *notfollowed = [Parcoa parser:let notFollowedBy:alphanum];
    
    NSString *input = @"lets arg1";
    ParcoaResult *ok = [let parseString:input];
    ParcoaResult *fail = [notfollowed parseString:input];
    
    STAssertTrue(ok.isOK, @"let will match lets.");
    STAssertTrue(fail.isFail, @"notfollow won't match lets.");
}

- (void)testParcoaSepBy1
{
    ParcoaParser *sepBy1 = [Parcoa sepBy1:[Parcoa string:@"Hello"] delimiter:[Parcoa string:@","]];
    ParcoaResult *failnone = [sepBy1 parseString:@""];
    ParcoaResult *ok = [sepBy1 parseString:@"Hello,Hello,Hello"];
    ParcoaResult *fail = [sepBy1 parseString:@"World,World,Hello"];
    
    STAssertTrue(failnone.isFail, @"Empty string shouldn't match.");
    STAssertTrue(ok.isOK, @"Hello,Hello,Hello should match.");
    STAssertTrue([ok.value count] == 3, @"OK value should have three elements.");
    STAssertTrue(fail.isFail, @"Hello,World,Hello shouldn't match.");
}

- (void)testPredicateCombinators {
    ParcoaPredicate *alphanum = [Parcoa inCharacterSet:[NSCharacterSet letterCharacterSet] setName:@"letter"];
    ParcoaPredicate *dash = [Parcoa isUnichar:'-'];
    ParcoaPredicate *both = [dash or: alphanum];
    STAssertFalse([dash check:'a'], @"a shouldn't match dash.");
    STAssertFalse([alphanum check:'-'], @"- shouldn't match alphanum.");
    
    STAssertTrue([both check:'a'], @"a should match both.");
    STAssertTrue([both check:'-'], @"dash should match both.");
}
@end
