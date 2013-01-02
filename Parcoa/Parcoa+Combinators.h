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

#import "Parcoa.h"

typedef id (^ParcoaValueTransform)(id value);

@interface Parcoa (Combinators)

/** @name Combining Parsers with Combinators */

/** Returns the result of the first matching parser in
 *  an array of parsers. Fails if no parsers match. */
+ (ParcoaParser)choice:(NSArray *)parsers;

/** Matches a parser n times. */
+ (ParcoaParser)count:(ParcoaParser)parser n:(NSUInteger)n;

/** Matches a parser zero or more times. */
+ (ParcoaParser)many:(ParcoaParser)parser;

/** Matches a parser one or more times. */
+ (ParcoaParser)many1:(ParcoaParser)parser;

/** Matches a parser zero or more times separated
 *  by a delimiter parser. */
+ (ParcoaParser)sepBy:(ParcoaParser)parser delimiter:(ParcoaParser)delimiter;

/** Matches a parser one or more times separated
 *  by a delimiter parser. */
+ (ParcoaParser)sepBy1:(ParcoaParser)parser delimiter:(ParcoaParser)delimiter;

/** Matches an array of parsers in order. If all parsers
 *  match OK then the result value is an array
 *  containing all of the individual parser's values. */
+ (ParcoaParser)sequential:(NSArray *)parsers;

/** Matches an array of parsers in order. If all parsers
 *  match OK then the result value is the value of the n'th
 *  matched parser. */
+ (ParcoaParser)sequential:(NSArray *)parsers keepIndex:(NSInteger)n;

/** Matches an array of parsers in order. If all parsers
 *  match OK then the result value is the value of the
 *  first matched parser. */
+ (ParcoaParser)sequentialKeepLeftMost:(NSArray *)parsers;

/** Matches an array of parsers in order. If all parsers
 *  match OK then the result value is the value of the
 *  last matched parser. */
+ (ParcoaParser)sequentialKeepRightMost:(NSArray *)parsers;

/** Matches a parser sandwiched between two "bookend" parsers.
 *  If the central and bookend parsers all match OK then the result
 *  value is the value of the central parser. */
+ (ParcoaParser)surrounded:(ParcoaParser)parser bookend:(ParcoaParser)bookend;

/** If the wrapped parser matches OK then the result value is
 *  transformed by the transform block. This operation
 *  is equivalent to bind on the ParcoaParser Monad. */
+ (ParcoaParser)transform:(ParcoaParser)parser by:(ParcoaValueTransform)transform;
@end
