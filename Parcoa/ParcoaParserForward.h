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

#import "Parcoaparser.h"

/** A forward declared parser.

  Consider a simple expression parser. Because expressions are recursively defined
  we use a forward declaration.
      
     // Forward declare an expression.
     ParcoaParserForward *expression = [ParcoaParserForward forwardWithName:@"expression"
     summary:@"expression forward declaration"];
     ParcoaParser *integer = [Parcoa integer];
     
     ParcoaParser *add      = [[Parcoa unichar:'+'] skipSurroundingSpaces];
     ParcoaParser *subtract = [[Parcoa unichar:'-'] skipSurroundingSpaces];
     ParcoaParser *multiply = [[Parcoa unichar:'*'] skipSurroundingSpaces];
     ParcoaParser *divide   = [[Parcoa unichar:'/'] skipSurroundingSpaces];
     
     ParcoaParser *term = [integer or: expression];
     term = [term sepByKeep:[multiply or: divide]];
     term = [term sepByKeep:[add or: subtract]];
     
     // Set the expression's implementation.
     [expression setImplementation:term];
 
*/
@interface ParcoaParserForward : ParcoaParser {
@private
    ParcoaParser *_implementation;
}
/// @name Define and Implement a Forward Declaration

/** Creates a new forward declaration with the given name and summary. */
+ (ParcoaParserForward *)forwardWithName:(NSString *)name summary:(NSString *)summary;

/** Sets the implementation of the forward declaration. Throws an exception if you
 * try and set the implementation more than once. */
- (void)setImplementation:(ParcoaParser *)parser;

@end
