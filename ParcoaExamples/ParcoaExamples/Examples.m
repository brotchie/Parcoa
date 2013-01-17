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

#import "Examples.h"

#import "ParcoaJSON.h"
#import "ParcoaRFC2616.h"

@implementation Examples
+ (void)jsonExample {
    NSString *input = @"[{\"name\" : \"Parcoa\",\n"
                       "  \"URL\"  : \"https://github.com/brotchie/Parcoa\",\n"
                       "  \"active\" : true}]";
    
    ParcoaResult *result = [[ParcoaJSON parser] parseString:input];
    id json = result.value;
    
    // ParcoaJSON parses JSON into valid Cocoa objects.
    NSLog(@"Project:%@ URL:%@ active:%@", json[0][@"name"], json[0][@"URL"], json[0][@"active"]);
    
    NSString *failInput = @"[{\"name\" : \"Parcoa\",\n"
    "  \"URL\"  : \"https://github.com/brotchie/Parcoa\"\n"
    "  \"active\" : true}]";
    ParcoaResult *failResult = [[ParcoaJSON parser] parseString:failInput];
    
    // On failure Parcoa can generate a traceback listing what input
    // was expected.
    NSLog(@"%@", [failResult traceback:failInput]);
}

+ (void)rfc2616Example {
    NSString *request = @"GET /index.html HTTP/1.1\r\n"
                         "Host: localhost\r\n"
                         "Accept: text/plain\r\n"
                         "\r\n";
    NSString *response = @"HTTP/1.0 200 OK\r\n"
                          "Content-Length: 0\r\n"
                          "Content-Type: text/plain\r\n"
                          "\r\n";
    
    ParcoaResult *requestResult = [[ParcoaRFC2616 requestParser] parseString:request];
    ParcoaResult *responseResult = [[ParcoaRFC2616 responseParser] parseString:response];
    
    NSLog(@"Request: %@", requestResult.value);
    NSLog(@"Response: %@", responseResult.value);
    
    // Convert the parser output into a clean request.
    NSMutableString *cleanRequest = [NSMutableString string];
    
    NSString *verb = requestResult.value[0][0];
    NSString *uri = requestResult.value[0][1];
    NSString *httpVersion = requestResult.value[0][2];
    
    [cleanRequest appendFormat:@"%@ %@ HTTP/%@\r\n", verb, uri, httpVersion];
    [requestResult.value[1] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = obj[0];
        NSString *value = obj[1];
        [cleanRequest appendFormat:@"%@: %@\r\n", key, value];
    }];
    [cleanRequest appendString:@"\r\n"];
    NSLog(@"%@", cleanRequest);
}
@end
