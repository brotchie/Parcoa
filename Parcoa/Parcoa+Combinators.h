//
//  Parcoa+Combinators.h
//  Parcoa
//
//  Created by James Brotchie on 30/12/12.
//  Copyright (c) 2012 Factorial Products Pty. Ltd. All rights reserved.
//

#import <Parcoa/Parcoa.h>

@interface Parcoa (Combinators)

+ (ParcoaParser)choice:(NSArray *)parsers;
+ (ParcoaParser)count:(ParcoaParser)parser n:(NSUInteger)n;
+ (ParcoaParser)many:(ParcoaParser)parser;
+ (ParcoaParser)many1:(ParcoaParser)parser;
+ (ParcoaParser)zeroOrOne:(ParcoaParser)parser;
+ (ParcoaParser)sepBy:(ParcoaParser)parser delimiter:(ParcoaParser)delimiter;
+ (ParcoaParser)sepBy1:(ParcoaParser)parser delimiter:(ParcoaParser)delimiter;

+ (ParcoaParser)sequential:(NSArray *)parsers;
+ (ParcoaParser)sequentialKeepLeftMost:(NSArray *)parsers;
+ (ParcoaParser)sequentialKeepRightMost:(NSArray *)parsers;
@end
