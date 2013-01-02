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
    ParcoaParser (^skipSurroundingSpace)(unichar c) = ^ParcoaParser(unichar c) {
        return [Parcoa surrounded:[Parcoa unicharLiteral:c] bookend:[Parcoa skipSpace]];
    };
    
    // Eliminate any white space surrounding delimiters.
    ParcoaParser kvSeparator  = skipSurroundingSpace(':');
    ParcoaParser comma        = skipSurroundingSpace(',');
    ParcoaParser openBrace    = skipSurroundingSpace('{');
    ParcoaParser closeBrace   = skipSurroundingSpace('}');
    ParcoaParser openBracket  = skipSurroundingSpace('[');
    ParcoaParser closeBracket = skipSurroundingSpace(']');
    
    ParcoaParser doubleQuote  = [Parcoa unicharLiteral:'"'];
    ParcoaParser integer = [Parcoa transform:[Parcoa takeWhile1InCharacterSet:[NSCharacterSet decimalDigitCharacterSet]]
                                          by:^id(id value) { return [NSNumber numberWithInteger:[value integerValue]]; }];
    
    ParcoaValueTransform packDictionary = ^id(id value) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            dict[obj[0]] = obj[1];
        }];
        return dict;
    };
    
    ParcoaForwardDeclaration(json);
    
    // null = "null"
    ParcoaParser null    = [Parcoa literal:@"null"];
    
    // boolean = "true" | "false"
    ParcoaParser boolean = [Parcoa choice:@[[Parcoa literal:@"true"], [Parcoa literal:@"false"]]];
    
    // string = "\"" + [^"]* "\""
    ParcoaParser string  = [Parcoa surrounded:[Parcoa takeUntil:[Parcoa isUnichar:'"']] bookend:doubleQuote];
    
    // pair = string + ":" + json
    ParcoaParser pair = [Parcoa sequential:@[[Parcoa sequentialKeepLeftMost:@[string, kvSeparator]], json]];
    
    // object = "{" + pair* + "}"
    ParcoaParser object  = [Parcoa transform:[Parcoa sequential:@[openBrace, [Parcoa sepBy:pair delimiter:comma], closeBrace] keepIndex:1]
                                         by:packDictionary];
    
    // list = "[" + json* + "]"
    ParcoaParser list = [Parcoa sequential:@[openBracket, [Parcoa sepBy:json delimiter:comma], closeBracket] keepIndex:1];
    
    // json = object | list | boolean | null | integer | string
    ParcoaForwardImpl(json) = [Parcoa choice:@[object, list, boolean, null, integer, string]];
    
    return json;
}
@end
