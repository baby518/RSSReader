//
//  ViewController.h
//  RSSReader
//
//  Created by zhangchao on 15/2/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FeedParser.h"
#import "FeedItemTableDelegate.h"

@protocol OpenUrlSheetDelegate;

@interface ViewController : NSViewController <FeedParserDelegate, NSTableViewDelegate, FeedChannelDelegate, NSTableViewDataSource>

@property (nonatomic, weak) id <OpenUrlSheetDelegate> urlSheetDelegate;
@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, strong, readonly) FeedParser *feedParser;

- (IBAction)openFileButtonPressed:(NSButton *)sender;
- (IBAction)addUrlButtonPressed:(NSButton *)sender;
- (IBAction)removeButtonAction:(NSButton *)sender;
- (IBAction)reloadButtonAction:(NSButton *)sender;
- (IBAction)didChannelLinkClicked:(NSButton *)sender;
- (void)startParse;
- (IBAction)stopParser:(NSButton *)sender;

- (NSString *)getFilePathFromDialog;
- (NSData *)loadDataFromFile:(NSString *)path;
- (void)openURL:(NSString *)urlString;

- (void)removeAllObjectsOfTable;
- (void)clearUIContents;
@end

