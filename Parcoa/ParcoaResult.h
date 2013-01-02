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

/** An immutable context tree that captures the state
 *  of a failed parser. */
@interface ParcoaFailContext : NSObject
/** The number of input characters remaining. */
@property (readonly) NSUInteger charactersRemaining;

/** A string describing what the parser expected. */
@property (readonly) NSString *expected;

/** An array containing ParcoaFailContext children. */
@property (readonly) NSArray *children;

/** Creates an immutable ParcoFailContext. */
+ (ParcoaFailContext *)contextWithRemaining:(NSString *)remaining expected:(NSString *)expected children:(NSArray *)children;

/** The minimum value of charactersRemaining for this context
 *  and all its children. This property is memoized such that
 *  subsequent calls are costless. */
- (NSUInteger)minCharactersRemaining;
@end

/** An immutable parsing result returned by every
 *  Parcoa parser. */
@interface ParcoaResult : NSObject

/** The result type: OK or Fail */
@property (readonly) ParcoaResultType type;

/** The fail context for the result. nil if type
 *  is OK. */
@property (readonly) ParcoaFailContext *context;

/** The residual input remaining after parsing. nil
 *  if type is Fail. */
@property (readonly) NSString *residual;

/** The parsed value. nil if type is Fail. */
@property (readonly) id value;

/** TRUE if OK. */
- (BOOL)isOK;

/** TRUE if Fail. */
- (BOOL)isFail;

/** Creates an OK result with value and residual input. */
+ (ParcoaResult *)ok:(id)value residual:(NSString *)residual;

/** Creates a Fail result. */
+ (ParcoaResult *)failWithRemaining:(NSString *)remaining expected:(NSString *)expected;

/** Creates a Fail result using a printf style format string. */
+ (ParcoaResult *)failWithRemaining:(NSString *)remaining expectedWithFormat:(NSString *)format, ...;

/** Creates a Fail result by aggregating the contexts of an array of failures as children. */
+ (ParcoaResult *)failWithFailures:(NSArray *)failures remaining:(NSString *)remaining expected:(NSString *)expected;

/** Creates a Fail result with this result's context as a child. */
- (ParcoaResult *)prependContextWithRemaining:(NSString *)remaining expected:(NSString *)expected;

/** Creates a Fail result with this result's context as a child; expected
 *  value generated using printf style format string. */
- (ParcoaResult *)prependContextWithRemaining:(NSString *)remaining expectedWithFormat:(NSString *)format, ...;

/** Generates a traceback of Parcoa contexts. If full is TRUE
 *  then a complete snapshot of the Parcoa context is given,
 *  if FALSE only the parser branch that consumed the most
 *  input is output.
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
