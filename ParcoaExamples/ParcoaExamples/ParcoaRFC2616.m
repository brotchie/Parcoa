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

#import "ParcoaRFC2616.h"

static ParcoaParser *_requestParser;
static ParcoaParser *_responseParser;

@interface ParcoaRFC2616 ()
+ (void)buildParsers;
@end

@implementation ParcoaRFC2616

+ (ParcoaParser *)requestParser {
    if (!_requestParser) {
        [ParcoaRFC2616 buildParsers];
    }
    return _requestParser;
}

+ (ParcoaParser *)responseParser {
    if (!_responseParser) {
        [ParcoaRFC2616 buildParsers];
    }
    return _responseParser;
}

+ (void)buildParsers {
    NSCharacterSet *tokenCharacters = [NSCharacterSet characterSetWithCharactersInString:@"()<>@,;:\\\"/[]?={} \t"];
    ParcoaPredicate *isToken = [ParcoaPredicate predicateWithBlock:^BOOL(unichar x) {
        return x >= 32 && x <= 127 && ![tokenCharacters characterIsMember:x];
    } name:@"isToken" summary:@"RFC2616 Token Character"];
    
    ParcoaParser *token           = [Parcoa takeWhile1:isToken];
    ParcoaParser *space           = [Parcoa space];
    ParcoaParser *newline         = [[Parcoa string:@"\r\n"] or: [Parcoa unichar:'\n']];
    ParcoaParser *headerSeparator = [[Parcoa unichar:':'] skipSurroundingSpaces];
    ParcoaParser *restOfLine      = [[Parcoa takeUntil:[Parcoa isUnichar:'\r']] keepLeft:newline];
    
    ParcoaParser *versionNumber   = [Parcoa takeWhile1:[Parcoa inClass:@"0123456789."]];
    ParcoaParser *version         = [[Parcoa string:@"HTTP/"] keepRight:versionNumber];
    ParcoaParser *responseCode    = [Parcoa integer];
    
    ParcoaParser *uri = [Parcoa takeUntil:[Parcoa isSpace]];
    
    ParcoaParser *requestLine  = [Parcoa sequential:@[
                                  [token keepLeft:space],
                                  [uri keepLeft:space],
                                  [version keepLeft:newline]]];

    ParcoaParser *responseLine = [Parcoa sequential:@[
                                  [version keepLeft:space],
                                  [responseCode keepLeft:space],
                                  restOfLine]];
    
    ParcoaParser *messageHeader  = [[token keepLeft: headerSeparator] then: restOfLine];
    ParcoaParser *messageHeaders = [[messageHeader many] keepLeft: newline];
    
    
    _requestParser  = [requestLine then: messageHeaders];
    _responseParser = [responseLine then: messageHeaders];

}

@end
