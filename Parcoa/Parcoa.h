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

#import <Foundation/Foundation.h>
#import "ParcoaResult.h"

typedef ParcoaResult *(^ParcoaParser)(NSString *input);
typedef BOOL (^ParcoaUnicharPredicate)(unichar);

@interface Parcoa : NSObject
+ (ParcoaResult *)runParserWithTraceback:(ParcoaParser)parser input:(NSString *)input;
+ (ParcoaParser)annotate:(ParcoaParser)parser expected:(NSString *)expected;
+ (ParcoaParser)annotate:(ParcoaParser)parser expectedWithFormat:(NSString *)format, ...;

+ (ParcoaParser)unicharLiteral:(unichar)c;
+ (ParcoaParser)literal:(NSString *)c;
+ (ParcoaParser)peek:(NSString *)c;
+ (ParcoaParser)take:(NSUInteger)n;

+ (ParcoaParser)takeOnce:(ParcoaUnicharPredicate)condition;
+ (ParcoaParser)takeWhile:(ParcoaUnicharPredicate)condition;
+ (ParcoaParser)takeWhile1:(ParcoaUnicharPredicate)condition;
+ (ParcoaParser)takeUntil:(ParcoaUnicharPredicate)condition;

+ (ParcoaParser)takeWhileInCharacterSet:(NSCharacterSet *)set;
+ (ParcoaParser)takeWhile1InCharacterSet:(NSCharacterSet *)set;

+ (ParcoaParser)takeWhileInClass:(NSString *)unichars;
+ (ParcoaParser)takeWhile1InClass:(NSString *)unichars;

+ (ParcoaParser)skipSpace;

+ (ParcoaParser)atEnd;
+ (ParcoaParser)endOfInput;

+ (ParcoaUnicharPredicate)isUnichar:(unichar)c;
+ (ParcoaUnicharPredicate)inCharacterSet:(NSCharacterSet *)set;
+ (ParcoaUnicharPredicate)inClass:(NSString *)unichars;
@end

/** Macros for forward declaration of recursive rules. */
#define __ParcoaMacroConcat(A,B) A ## B
#define __ParcoaForwardVariable(NAME) __ParcoaMacroConcat(__parcoa_forward_impl_,NAME)

#define ParcoaForwardDeclaration(NAME) \
__block ParcoaParser __ParcoaForwardVariable(NAME); \
ParcoaParser NAME = ^ParcoaResult *(NSString *input) { \
return __ParcoaForwardVariable(NAME)(input); \
}

#define ParcoaForwardImpl(NAME) __ParcoaForwardVariable(NAME)
