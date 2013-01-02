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
