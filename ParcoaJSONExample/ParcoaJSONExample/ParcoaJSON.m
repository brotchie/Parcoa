//
//  ParcoaJSON.m
//  ParcoaJSONExample
//
//  Created by James Brotchie on 30/12/12.
//  Copyright (c) 2012 Factorial Products Pty. Ltd. All rights reserved.
//

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
