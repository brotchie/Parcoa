//
//  Examples.m
//  ParcoaExamples
//
//  Created by James Brotchie on 4/01/13.
//  Copyright (c) 2013 Factorial Products Pty. Ltd. All rights reserved.
//

#import "Examples.h"

#import "ParcoaJSON.h"
#import "ParcoaRFC2616.h"

@implementation Examples
+ (void)jsonExample {
    NSString *input = @"[{\"name\" : \"Parcoa\",\n"
                       "  \"URL\"  : \"https://github.com/brotchie/Parcoa\",\n"
                       "  \"active\" : true}]";
    
    ParcoaResult *result = [[ParcoaJSON parser] parse:input];
    id json = result.value;
    
    // ParcoaJSON parses JSON into valid Cocoa objects.
    NSLog(@"Project:%@ URL:%@ active:%@", json[0][@"name"], json[0][@"URL"], json[0][@"active"]);
    
    NSString *failInput = @"[{\"name\" : \"Parcoa\",\n"
    "  \"URL\"  : \"https://github.com/brotchie/Parcoa\"\n"
    "  \"active\" : true}]";
    ParcoaResult *failResult = [[ParcoaJSON parser] parse:failInput];
    
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
    
    ParcoaResult *requestResult = [[ParcoaRFC2616 requestParser] parse:request];
    ParcoaResult *responseResult = [[ParcoaRFC2616 responseParser] parse:response];
    
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
