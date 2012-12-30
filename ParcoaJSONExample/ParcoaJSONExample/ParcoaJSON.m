//
//  ParcoaJSON.m
//  ParcoaJSONExample
//
//  Created by James Brotchie on 30/12/12.
//  Copyright (c) 2012 Factorial Products Pty. Ltd. All rights reserved.
//

#import "ParcoaJSON.h"

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

+ (ParcoaParser)buildParser {
    
}
@end
