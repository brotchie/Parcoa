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

#import "FPAppDelegate.h"
#import "ParcoaJSON.h"

@implementation FPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //NSLog(@"%d", [@"false" boolValue]);
    NSString *json = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"example" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    json = @"[1 2]";
    //ParcoaResult *result = [Parcoa runParserWithTraceback:[ParcoaJSON parser] input:json];
    ParcoaResult *result = [[ParcoaJSON parser] parse:json];
    if (result.isOK) {
        NSLog(@"%@", result.value);
    } else {
        NSLog(@"%@",[result traceback:json full:NO]);
    }
    /*[Parcoa runParserWithTraceback:[ParcoaRFC2616 requestParser] input:@"GET /index.html HTTP/1.0\r\nUser-agent: test\r\ncookies: testing 1234\r\n\r\n"];
    NSLog(@"%@", [ParcoaRFC2616 responseParser](@"HTTP/1.0 200 OK\r\nContent-Type: text/plain\r\n\r\n"));*/
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
