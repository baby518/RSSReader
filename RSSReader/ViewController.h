//
//  ViewController.h
//  RSSReader
//
//  Created by zhangchao on 15/2/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RSSParser.h"

@interface ViewController : NSViewController <RSSParserDelegate, NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, strong, readonly) RSSParser *rssParser;

@property (weak) IBOutlet NSTextField *filePathTextField;
@property (weak) IBOutlet NSTextField *channelTitleTextField;
@property (weak) IBOutlet NSTextField *channelLinkTextField;
@property (weak) IBOutlet NSTextField *channelDescriptionTextField;
@property (weak) IBOutlet NSTextField *channelPubDateTextField;
@property (weak) IBOutlet NSButton *channelLinkButton;
@property (weak) IBOutlet NSButton *startParseButton;
@property (weak) IBOutlet NSPopUpButton *parseModePopUp;

- (IBAction)openFileButtonPressed:(NSButton *)sender;
- (IBAction)startParserButtonPressed:(NSButton *)sender;
- (IBAction)didChannelLinkClicked:(NSButton *)sender;
- (void) startParseData:(NSData *)data;

- (NSString *)getFilePathFromDialog;
- (NSData *)loadDataFromFile:(NSString *)path;
- (void)openURL:(NSString *)urlString;

- (void)removeAllObjectsOfTable;
- (void)clearUIContents;

@end

