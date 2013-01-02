//
//  ParcoaRFC2616.m
//  ParcoaJSONExample
//
//  Created by James Brotchie on 1/01/13.
//  Copyright (c) 2013 Factorial Products Pty. Ltd. All rights reserved.
//

#import "ParcoaRFC2616.h"
#import "Parcoa+Combinators.h"

static ParcoaParser _requestParser;
static ParcoaParser _responseParser;

@interface ParcoaRFC2616 ()
+ (void)buildParsers;
@end

@implementation ParcoaRFC2616

#pragma mark - Singleton Accessors

+ (ParcoaParser)requestParser {
    if (!_requestParser) {
        [ParcoaRFC2616 buildParsers];
    }
    return _requestParser;
}

+ (ParcoaParser)responseParser {
    if (!_responseParser) {
        [ParcoaRFC2616 buildParsers];
    }
    return _responseParser;
}

#pragma mark - Parser Construction

+ (void)buildParsers {
    NSCharacterSet *tokenCharacters = [NSCharacterSet characterSetWithCharactersInString:@"()<>@,;:\\\"/[]?={} \t"];
    ParcoaUnicharPredicate isToken = ^BOOL(unichar c) {
        return c >= 32 && c <= 127 && ![tokenCharacters characterIsMember:c];
    };
    ParcoaUnicharPredicate isSpace = [Parcoa isUnichar:' '];
    ParcoaUnicharPredicate isEndOfLine = [Parcoa inClass:@"\r\n"];
    ParcoaUnicharPredicate isDigit = [Parcoa inClass:@"0123456789"];
    ParcoaUnicharPredicate isDigitOrDecimal = [Parcoa inClass:@"0123456789."];
    
    ParcoaParser token = [Parcoa takeWhile1:isToken];
    ParcoaParser singleSpace = [Parcoa takeOnce:isSpace];
    ParcoaParser horizontalSpace = [Parcoa takeWhile:isSpace];
    ParcoaParser endOfLine = [Parcoa choice:@[
                              [Parcoa literal:@"\r\n"],
                              [Parcoa unicharLiteral:'\n']]];
    
    ParcoaParser headerSep = [Parcoa unicharLiteral:':'];
    ParcoaParser httpVersion = [Parcoa sequentialKeepRightMost:@[
                                [Parcoa literal:@"HTTP/"],
                                [Parcoa takeWhile1:isDigitOrDecimal]]];
    ParcoaParser responseCode = [Parcoa takeWhile1:isDigit];
    ParcoaParser uri = [Parcoa takeUntil:isSpace];
    
    ParcoaParser requestLine    = [Parcoa annotate:[Parcoa sequential:@[
                                   [Parcoa sequentialKeepLeftMost:@[token, singleSpace]],
                                   [Parcoa sequentialKeepLeftMost:@[uri, singleSpace]],
                                   [Parcoa sequentialKeepLeftMost:@[httpVersion, endOfLine]]]]
                                          expected:@"Expected request line."];
    
    ParcoaParser responseLine   = [Parcoa annotate:[Parcoa sequential:@[
                                   [Parcoa sequentialKeepLeftMost:@[httpVersion, singleSpace]],
                                   [Parcoa sequentialKeepLeftMost:@[responseCode, singleSpace]],
                                   [Parcoa sequentialKeepLeftMost:@[[Parcoa takeUntil:isEndOfLine], endOfLine]]]]
                                          expected:@"Expected response line."];
    
    ParcoaParser messageHeader  = [Parcoa annotate:[Parcoa sequential:@[
                                   [Parcoa sequentialKeepLeftMost:@[token, headerSep, horizontalSpace]],
                                   [Parcoa sequentialKeepLeftMost:@[[Parcoa takeUntil:isEndOfLine], endOfLine]]]]
                                          expected:@"Expected message header."];
    
    ParcoaParser messageHeaders = [Parcoa sequentialKeepLeftMost:@[[Parcoa many1:messageHeader], endOfLine]];
    
    ParcoaParser request = [Parcoa sequential:@[requestLine, messageHeaders]];
    ParcoaParser response = [Parcoa sequential:@[responseLine, messageHeaders]];
    
    _requestParser = request;
    _responseParser = response;
}

@end
