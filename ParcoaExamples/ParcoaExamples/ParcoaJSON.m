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

#import "ParcoaJSON.h"

static ParcoaParser *_parser;

@interface ParcoaJSON ()
+ (ParcoaParser *)buildParser;
@end

@implementation ParcoaJSON

+ (ParcoaParser *)parser {
    if (!_parser) {
        _parser = [ParcoaJSON buildParser];
    }
    return _parser;
}

+ (ParcoaParser *)buildParser {
    ParcoaParser *colon        = [[Parcoa unichar:':'] skipSurroundingSpaces];
    ParcoaParser *comma        = [[Parcoa unichar:','] skipSurroundingSpaces];
    ParcoaParser *openBrace    = [[Parcoa unichar:'{'] skipSurroundingSpaces];
    ParcoaParser *closeBrace   = [[Parcoa unichar:'}'] skipSurroundingSpaces];
    ParcoaParser *openBracket  = [[Parcoa unichar:'['] skipSurroundingSpaces];
    ParcoaParser *closeBracket = [[Parcoa unichar:']'] skipSurroundingSpaces];
    
    ParcoaParser *quote         = [Parcoa unichar:'"'];
    ParcoaParser *notQuote      = [Parcoa noneOf:@"\""];
    ParcoaParser *escapedQuote  = [Parcoa string:@"\\\""];
    ParcoaParser *stringContent = [Parcoa concatMany:[escapedQuote or: notQuote]];
    
    ParcoaParserForward *json = [ParcoaParserForward forwardWithName:@"json" summary:@"json forward declaration"];
    
    ParcoaParser *string  = [stringContent between:quote and: quote];
    ParcoaParser *null    = [Parcoa string:@"null"];
    ParcoaParser *boolean = [Parcoa bool];
    ParcoaParser *integer = [Parcoa integer];
    ParcoaParser *pair    = [[string keepLeft: colon] then: json];
    ParcoaParser *object  = [[[pair sepBy:comma] between:openBrace   and: closeBrace] dictionary];
    ParcoaParser *list    =  [[json sepBy:comma] between:openBracket and: closeBracket];

    [json setImplementation:[Parcoa choice:@[object, list, string, integer, boolean, null]]];
    
    return json;
}

@end
