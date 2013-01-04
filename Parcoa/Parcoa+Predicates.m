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

#import "Parcoa+Predicates.h"

@implementation Parcoa (Predicates)

+ (ParcoaPredicate *)isUnichar:(unichar)c {
    return [ParcoaPredicate predicateWithBlock:^BOOL(unichar x) {
        return x == c;
    } name:@"isUnichar" summaryWithFormat:@"'%c'", c];
}

+ (ParcoaPredicate *)inCharacterSet:(NSCharacterSet *)set setName:(NSString *)setName {
    return [ParcoaPredicate predicateWithBlock:^BOOL(unichar x) {
        return [set characterIsMember:x];
    } name:@"inCharacterSet" summary:setName];
}

+ (ParcoaPredicate *)inClass:(NSString *)unichars {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:unichars];
    return [[Parcoa inCharacterSet:set setName:nil] predicateWithName:@"inClass" summary:unichars];
}

+ (ParcoaPredicate *)not:(ParcoaPredicate *)predicate {
    return [ParcoaPredicate predicateWithBlock:^BOOL(unichar x) {
        return ![predicate check:x];
    } name:@"not" summary:predicate.description];
}

+ (ParcoaPredicate *)isSpace {
    return [Parcoa inCharacterSet:[NSCharacterSet whitespaceCharacterSet] setName:@"whitespace"];
}

@end
