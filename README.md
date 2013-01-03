#Parcoa
## Parser Combinators for Objective-C
**Parcoa** is a collection of parsers and parser combinators for Objective-C inspired by Haskell's [Parsec](http://www.haskell.org/haskellwiki/Parsec) package. It is released under a MIT license.

### Pure Parcoa Parsers
A Parcoa parser is any pure function that takes a single `NSString *` argument, attempts to parse some value from this string, then returns an `OK` or `Fail` result. On success, the parser returns both the parsed *value* and the unconsumed *residual* input. On failure the parser returns a string description of what it *expected* to find in the input.

![Parser Diagram](https://raw.github.com/brotchie/Parcoa/master/docs/diagrams/parser.png)

Consider a very simple parser that expects the unicode character `'a'`

    ParcoaParser simpleA = [Parcoa unichar:'a'];

If we pass it the string `"abcd"`, it parses the first character and returns an OK result:

    ParcoaResult *result = simpleA(@"abcd");
    
    result.isOK == TRUE
    result.value == @"a"

If there's no leading `'a'` then parsing fails:

    ParcoaResult *result = simpleA(@"bcd");
    
    result.isFail == TRUE

### What the heck is a parser combinator?
Although simple and self-contained, basic Parcoa parsers are useless in isolation. A [parser combinator](http://en.wikipedia.org/wiki/Parser_combinator) is a function that takes one or more parsers and creates a *new* parser with added functionality. Combined parsers can be further combined, enabling complex parsing behaviour via composition of parsing primatives.

For example, instead of a single `'a'` character, we can match any consecutive sequence of a's

```
ParcoaParser manyA = [Parcoa many:simpleA];

ParcoaResult *result = manyA(@"aaaabcd");

result.isOK == TRUE
result.value == @[@"a", @"a", @"a", @"a"]]
```

Perhaps we want to match any consecutive sequence of a's *or* the string `"hello"`
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
    

