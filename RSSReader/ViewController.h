//
//  ViewController.h
//  RSSReader
//
//  Created by zhangchao on 15/2/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FeedParser.h"

typedef NS_ENUM(NSInteger, XMLSource) {
    /** parse local file.*/
    XMLSourceLocalFile = 0,
    /** parse URL Feed.*/
    XMLSourceURL = 1,
};
#define XMLSourceArrays @[@"LocalFile", @"URL"]

@interface ViewController : NSViewController <FeedParserDelegate, NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, strong, readonly) FeedParser *feedParser;

@property (weak) IBOutlet NSTextField *filePathTextField;
@property (weak) IBOutlet NSTextField *channelTitleTextField;
@property (weak) IBOutlet NSTextField *channelLinkTextField;
@property (weak) IBOutlet NSTextField *channelDescriptionTextField;
@property (weak) IBOutlet NSTextField *channelLanguageTextField;
@property (weak) IBOutlet NSTextField *channelPubDateTextField;
@property (weak) IBOutlet NSButton *channelLinkButton;
@property (weak) IBOutlet NSButton *startParseButton;
@property (weak) IBOutlet NSPopUpButton *xmlSourcePopup;
@property (weak) IBOutlet NSPopUpButton *elementStringStylePopUp;
@property (weak) IBOutlet NSPopUpButton *parseEnginePopup;
@property (weak) IBOutlet NSButton *useHTMLLabelCheckBox;
@property (weak) IBOutlet NSButton *openLocalFileButton;
@property (weak) IBOutlet NSButton *loadUrlButton;

- (IBAction)didXmlSourceChoose:(NSPopUpButton *)sender;
- (IBAction)openFileButtonPressed:(NSButton *)sender;
- (IBAction)startParserButtonPressed:(NSButton *)sender;
- (IBAction)loadUrlButtonPressed:(NSButton *)sender;
- (IBAction)didChannelLinkClicked:(NSButton *)sender;
- (void) startParseData:(NSData *)data;

- (NSString *)getFilePathFromDialog;
- (NSData *)loadDataFromFile:(NSString *)path;
- (void)openURL:(NSString *)urlString;

- (void)removeAllObjectsOfTable;
- (void)clearUIContents;

@end

