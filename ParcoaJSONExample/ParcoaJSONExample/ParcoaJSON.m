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

#import "ParcoaJSON.h"
#import "Parcoa+Combinators.h"
#import "Parcoa+Numbers.h"
#import "Parcoa+NSDictionary.h"

static ParcoaParser _parser;

@interface ParcoaJSON ()
+ (ParcoaParser)buildParser;
@end

@implementation ParcoaJSON
+ (ParcoaParser)parser {
    if (!_parser) {
        _parser = [ParcoaJSON buildParser];
    }
    return _parser;
}

#pragma mark - Parser Construction

+ (ParcoaParser)buildParser {
    ParcoaParser colon        = [Parcoa skipSurroundingSpaces:[Parcoa unichar:':']];
    ParcoaParser comma        = [Parcoa skipSurroundingSpaces:[Parcoa unichar:',']];
    ParcoaParser openBrace    = [Parcoa skipSurroundingSpaces:[Parcoa unichar:'{']];
    ParcoaParser closeBrace   = [Parcoa skipSurroundingSpaces:[Parcoa unichar:'}']];
    ParcoaParser openBracket  = [Parcoa skipSurroundingSpaces:[Parcoa unichar:'[']];
    ParcoaParser closeBracket = [Parcoa skipSurroundingSpaces:[Parcoa unichar:']']];
    
    ParcoaParser quote         = [Parcoa unichar:'"'];
    ParcoaParser notQuote      = [Parcoa noneOf:@"\""];
    ParcoaParser escapedQuote  = [Parcoa string:@"\\\""];
    ParcoaParser stringContent = [Parcoa concatMany:[Parcoa choice:@[escapedQuote, notQuote]]];
    
    ParcoaForwardDeclaration(json);
    
    ParcoaParser string  = [Parcoa between:quote parser:stringContent right:quote];
    ParcoaParser null    = [Parcoa string:@"null"];
    ParcoaParser boolean = [Parcoa bool];
    ParcoaParser integer = [Parcoa integer];
    ParcoaParser pair    = [Parcoa sequential:@[[Parcoa sequentialKeepLeftMost:@[string, colon]], json]];
    ParcoaParser object  = [Parcoa dictionary:[Parcoa between:openBrace parser:[Parcoa sepBy:pair delimiter:comma] right:closeBrace]];
    ParcoaParser list    = [Parcoa between:openBracket parser:[Parcoa sepBy:json delimiter:comma] right:closeBracket];

    ParcoaForwardImpl(json) = [Parcoa choice:@[object, list, string, integer, boolean, null]];
    
    return json;
}
@end
