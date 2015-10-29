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
@property (nonatomic, assign, readonly) long numberOfRows;
@property (nonatomic, strong, readonly) RSSChannelElement *currentChannel;

@property (weak) IBOutlet NSTextField *localPathTextField;
@property (weak) IBOutlet NSTextField *webPathTextField;
@property (weak) IBOutlet NSTextField *channelTitleTextField;
@property (weak) IBOutlet NSTextField *channelLinkTextField;
@property (weak) IBOutlet NSTextField *channelDescriptionTextField;
@property (weak) IBOutlet NSTextField *channelLanguageTextField;
@property (weak) IBOutlet NSTextField *channelPubDateTextField;
@property (weak) IBOutlet NSButton *channelFavIconImageView;
@property (weak) IBOutlet NSPopUpButton *elementStringStylePopUp;
@property (weak) IBOutlet NSPopUpButton *parseEnginePopup;
@property (weak) IBOutlet NSButton *useHTMLLabelCheckBox;
@property (weak) IBOutlet NSButton *openLocalFileButton;
@property (weak) IBOutlet NSButton *loadWebUrlButton;
@property (weak) IBOutlet NSTableView *feedItemsTableView;
@property (strong) IBOutlet NSButton *stopLocalParserButton;
@property (strong) IBOutlet NSButton *stopWebParserButton;

- (IBAction)openFileButtonPressed:(NSButton *)sender;
- (IBAction)loadUrlButtonPressed:(NSButton *)sender;
- (IBAction)didChannelLinkClicked:(NSButton *)sender;
- (void) startParse;
- (IBAction)stopParser:(NSButton *)sender;

- (NSString *)getFilePathFromDialog;
- (NSData *)loadDataFromFile:(NSString *)path;
- (void)openURL:(NSString *)urlString;

- (void)removeAllObjectsOfTable;
- (void)clearUIContents;

@end

