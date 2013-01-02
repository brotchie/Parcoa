#Parcoa
## Parser Combinators for Objective-C
**Parcoa** is a collection of parsers and parser combinators for Objective-C inspired by Haskell's [Parsec](http://www.haskell.org/haskellwiki/Parsec) package.

### What the heck is a parser combinator?
Consider a very simple parser that parses the unicode character `'a'`

    ParcoaParser simpleA = [Parcoa unichar:'a'];

If we pass it the string `"abcd"` it parses the first character and returns an OK result:

    ParcoaResult *result = simpleA(@"abcd");
    NSAssert(result.isOK, @"simpleA parser should parse abcd.");
    NSAssert([result.value isEqualToString:@"a"],
             @"simpleA parser should return value 'a'");

If there's no leading `'a'` then parsing fails:

    ParcoaResult *result = simpleA(@"bcd");
    NSAssert(result.isFail, @"simpleA parser shouldn't parse bcd.");
    
A [parser combinator](http://en.wikipedia.org/wiki/Parser_combinator) is simply a function that takes one or more parsers as arguments and creates a *new* parser with added functionality.

```
// Parse input with simpleA again-and-again until parsing fails.
ParcoaParser manyA = [Parcoa many:simpleA];

ParcoaResult *result = manyA(@"aaaabcd");
NSAssert(result.isOK, @"manyA parser should parse aaaabcd");
NSAssert([result.value isEqual:@[@"a", @"a", @"a", @"a"]]);
```

```
ParcoaParser hello = [Parcoa string:@"hello"];
ParcoaParser manyAConcat = [Parcoa concat:manyA];
ParcoaParser thisorthat = [Parcoa choice:@[manyAConcat, hello]];

ParcoaResult *result = thisorthat(@"helloworld");
NSAssert(result.isOK);
NSAssert([result.value isEqual:@"hello"]);

result = thisorthat(@"aaaaaworld");
NSAssert(result.isOK);
NSAssert([result.value isEqual:@"aaaaa"]);

```
    

