#Parcoa
## Parser Combinators for Objective-C
**Parcoa** is a collection of parsers and parser combinators for Objective-C inspired by Haskell's [Parsec](http://www.haskell.org/haskellwiki/Parsec) package. It is released under a MIT license.

### Pure Parcoa Parsers
A Parcoa parser is any pure function that takes a single `NSString *` argument, attempts to parse some value from this string, then returns an `OK` or `Fail` result. On success the parser returns both the parsed value and the unconsumed residual input. On failure the parser returns a string description of what it *expected* to find in the input.

![Parser Diagram](https://raw.github.com/brotchie/Parcoa/master/docs/diagrams/parser.png)

Consider a very simple parser that expects the unicode character `'a'`

    ParcoaParser simpleA = [Parcoa unichar:'a'];

If we pass it the string `"abcd"` it parses the first character and returns an OK result:

    ParcoaResult *result = simpleA(@"abcd");
    
    result.isOK == TRUE
    result.value == @"a"

If there's no leading `'a'` then parsing fails:

    ParcoaResult *result = simpleA(@"bcd");
    
    result.isFail == TRUE

### What the heck is a parser combinator?
A [parser combinator](http://en.wikipedia.org/wiki/Parser_combinator) is simply a function that takes one or more parsers as arguments and creates a *new* parser with added functionality.

```
// Parse input with simpleA again-and-again until parsing fails.
ParcoaParser manyA = [Parcoa many:simpleA];

ParcoaResult *result = manyA(@"aaaabcd");

result.isOK == TRUE
result.value == @[@"a", @"a", @"a", @"a"]]
```

```
ParcoaParser hello = [Parcoa string:@"hello"];
ParcoaParser manyAConcat = [Parcoa concat:manyA];
ParcoaParser thisorthat = [Parcoa choice:@[manyAConcat, hello]];

ParcoaResult *result = thisorthat(@"helloworld");

result.isOK == TRUE
result.value == @"hello"

result = thisorthat(@"aaaaaworld");
result.isOK == TRUE
result.value = @"aaaaa"

```
    

