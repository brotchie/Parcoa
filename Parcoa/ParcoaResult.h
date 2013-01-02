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

typedef enum {
    ParcoaResultFail,
    ParcoaResultOK
} ParcoaResultType;

@interface ParcoaFailContext : NSObject
@property (readonly) NSUInteger charactersRemaining;
@property (readonly) NSString *expected;
@property (readonly) NSArray *children;
+ (ParcoaFailContext *)contextWithRemaining:(NSString *)remaining expected:(NSString *)expected children:(NSArray *)children;
- (NSUInteger)minCharactersRemaining;
@end

@interface ParcoaResult : NSObject
@property (readonly) ParcoaResultType type;
@property (readonly) ParcoaFailContext *context;
@property (readonly) NSString *residual;
@property (readonly) id value;

- (BOOL)isFail;
- (BOOL)isOK;

- (ParcoaResult *)prependContextWithRemaining:(NSString *)remaining expected:(NSString *)expected;
- (ParcoaResult *)prependContextWithRemaining:(NSString *)remaining expectedWithFormat:(NSString *)format, ...;

+ (ParcoaResult *)failWithFailures:(NSArray *)failures remaining:(NSString *)remaining expected:(NSString *)expected;
+ (ParcoaResult *)failWithRemaining:(NSString *)remaining expected:(NSString *)expected;
+ (ParcoaResult *)failWithRemaining:(NSString *)remaining expectedWithFormat:(NSString *)format, ...;
+ (ParcoaResult *)ok:(id)value residual:(NSString *)residual;

/** Generates a traceback of Parcoa contexts. If full is TRUE
 *  then a complete snapshot of the Parcoa context is given,
 *  if FALSE only the parser branch that consumed the most
 *  input is shown.
 *
 * @param input The previously supplied parser input.
 * @param full TRUE for all contexts, FALSE for the context
 *        the consumed the most input.
 * @return A traceback containing line and column numbers
 *         along with details of what the parser expected.
 */
- (NSString *)traceback:(NSString *)input full:(BOOL)full;
- (NSString *)traceback:(NSString *)input;

@end
