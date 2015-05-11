//
//  XMLParser.m
//  RSSReader
//
//  Created by zhangchao on 15/2/5.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "FeedParser.h"
#import "NSRSSParser.h"
#import "GDataRSSParser.h"

#pragma mark FeedParser (private)
@interface FeedParser ()
@property(nonatomic, strong, readonly) NSURL *feedURL;

- (void)initializeData:(NSData *)data;
@end

#pragma mark FeedParser
@implementation FeedParser

- (id)initWithData:(NSData *)data {
    self = [super self];
    if (self) {
        [self initializeData:data];
    }
    return self;
}

- (id)initWithURL:(NSURL *)feedURL {
    self = [super self];
    if (self) {
        _feedURL = feedURL;
    }
    return self;
}

- (void)startRequestSync:(NSError **)errorPtr {
    NSError *urlError = nil;
    // Method 1 : use NSData load URL
    NSData *urlData = [NSData dataWithContentsOfURL:self.feedURL options:NSDataReadingMappedIfSafe error:&urlError];
    if (urlData && !urlError) {
        [self initializeData:urlData];
    } else {
        LOGE(@"initWithURL loadDataFromURL error is %@", urlError);
        if (urlError && errorPtr) {
            *errorPtr = [[NSError alloc] initWithDomain:urlError.domain code:urlError.code userInfo:urlError.userInfo];
        }
    }

//    // Method 2 : use NSURLConnection sync request
//    // Create default request with no caching
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.feedURL
//                                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
//                                                            timeoutInterval:60];
//    // Sync
//    NSURLResponse *response = nil;
//    NSError *error = nil;
//    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    if (data && !error) {
//        [self initializeData:data];
//    } else {
//        LOGE(@"loadDataFromURL error is %@", error);
//        if (error && errorPtr) {
//            *errorPtr = [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:error.userInfo];
//        }
//    }
}

- (void)startRequestAsync:(void (^)(NSError *error))handler {
    // Method 3: use NSURLConnection Async copy from SeismicXML
    NSURLRequest *feedURLRequest = [NSURLRequest requestWithURL:self.feedURL];

    [NSURLConnection sendAsynchronousRequest:feedURLRequest
            // the NSOperationQueue upon which the handler block will be dispatched:
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               // back on the main thread, check for errors, if no errors start the parsing
                               // here we check for any returned NSError from the server, "and" we also check for any http response errors
                               if (error != nil) {
                                   LOGE(@"NSURLConnection error is %@", error);
                                   handler(error);
                               } else {
                                   // check for any response errors
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                   if ((([httpResponse statusCode] / 100) == 2) &&
                                           ([[response MIMEType] isEqual:RSS_MIME_TYPE] || [[response MIMEType] isEqual:RSS_MIME_TYPE_XML]
                                                   || [[response MIMEType] isEqual:RSS_MIME_TYPE_XML2])) {
                                       // the XML data.
                                       [self initializeData:data];
                                       handler(nil);
                                   } else {
                                       NSString *errorString = [NSString stringWithFormat:@"%@ : %@",
                                                       feedURLRequest.URL, @"Error message displayed when receving a connection error."];
                                       NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorString};
                                       NSError *reportError = [NSError errorWithDomain:@"HTTP"
                                                                                  code:[httpResponse statusCode]
                                                                              userInfo:userInfo];
                                       LOGE(@"NSURLConnection statusCode : %ld", [httpResponse statusCode]);
                                       LOGE(@"NSURLConnection MIMEType : %@", [httpResponse MIMEType]);
                                       LOGE(@"NSURLConnection http response error is %@", reportError);
                                       handler(reportError);
                                   }
                               }
                           }];
}

- (void)startParser {
    [self startParserWithStyle:XMLElementStringNormal];
}

- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle {
    [self startParserWithStyle:elementStringStyle parseEngine:NSXMLParseEngine];
}

- (void)startParserWithStyle:(XMLElementStringStyle)elementStringStyle parseEngine:(XMLParseEngine)engine {
    if (_xmlData == nil) {
        LOGW(@"return because xmlData is nil, may be Async NSURLConnection Request is not complete.");
        return;
    }
    // set engine
    _xmlParseEngine = engine;
    // Determine the Class for the parser
    switch (_xmlParseEngine) {
        case GDataXMLParseEngine:
            self.parser = [[GDataRSSParser alloc] initWithData:_xmlData];
            break;
        case NSXMLParseEngine:
            self.parser = [[NSRSSParser alloc] initWithData:_xmlData];
            break;
        default:
            NSAssert1(NO, @"Unknown parser type %ld", _xmlParseEngine);
            break;
    }
    if (self.parser != nil) {
        // Set parser's delegate.
        self.parser.delegate = self;
        // start parser
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.parser startParserWithStyle:elementStringStyle];
        });
    }
}

- (void)stopParser {
    if (self.parser != nil) {
        [self.parser stopParser];
    }
}

#pragma mark FeedParser (private)

- (void) initializeData:(NSData *)data {
    unsigned long size = [data length];
    LOGD(@"initializeData size : %lu Byte, %lu KB", size, size / 1024);
    _xmlData = data;
}

#pragma mark RSSParserDelegate

- (void)parseErrorOccurred:(NSError *)error {
    [self stopParser];
}

- (void)elementDidParsed:(RSSBaseElement *)element {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(elementDidParsed:)]) {
            [self.delegate elementDidParsed:element];
        }
    });
}

- (void)allElementsDidParsed {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(allElementsDidParsed)]) {
            [self.delegate allElementsDidParsed];
        }
    });
}

@end
