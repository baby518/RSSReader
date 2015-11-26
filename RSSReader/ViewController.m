//
//  ViewController.m
//  RSSReader
//
//  Created by zhangchao on 15/2/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "ViewController.h"
#import "NSDate+helper.h"
#import "AppDelegate.h"
#import "DBUtil.h"

NSString *const RELOAD_START_LABEL = @"reload";
NSString *const RELOAD_STOP_LABEL  = @"stop";

@interface ViewController ()
@property (nonatomic, strong) NSArray *allFeedChannels;
@property (nonatomic, strong) DBUtil *dbUtil;

// Channel's info and Items
@property (weak) IBOutlet NSTableView *feedItemsTableView;
@property (weak) IBOutlet NSTextField *feedUrlTextField;
@property (weak) IBOutlet NSTextField *channelTitleTextField;
@property (weak) IBOutlet NSTextField *channelDescriptionTextField;
@property (weak) IBOutlet NSTextField *channelLanguageTextField;
@property (weak) IBOutlet NSTextField *channelPubDateTextField;
@property (weak) IBOutlet NSButton *channelFavIconImageView;

// Local tab
@property (weak) IBOutlet NSPopUpButton *elementStringStylePopUp;
@property (weak) IBOutlet NSPopUpButton *parseEnginePopup;
@property (weak) IBOutlet NSButton *useHTMLLabelCheckBox;
@property (weak) IBOutlet NSButton *openLocalFileButton;
@property (weak) IBOutlet NSButton *stopLocalParserButton;
// Web tab
@property (nonatomic, strong) FeedItemTableDelegate *feedItemTableDelegate;
@property (weak) IBOutlet NSTableView *databaseTableView;
@property (weak) IBOutlet NSButton *reloadFeedButton;

@property (nonatomic, strong, readonly) RSSChannelElement *channelElementToShow;
@end

@implementation ViewController

/** use viewDidLoad on OSX 10.10 + */
- (void)loadView {
    [super loadView];

    _dbUtil = [[DBUtil alloc] init];

    _feedItemTableDelegate = [[FeedItemTableDelegate alloc] initWithChannelDelegate:self];
    self.feedItemsTableView.delegate = self.feedItemTableDelegate;
    self.feedItemsTableView.dataSource = self.feedItemTableDelegate;

    // Local tab
    [_elementStringStylePopUp addItemsWithTitles:XMLElementStringStyleArrays];
    [_parseEnginePopup addItemsWithTitles:XMLParseEngineArrays];

    // Web tab
    self.reloadFeedButton.title = RELOAD_START_LABEL;

    [self reloadChannelsListFromDB];
    [self.databaseTableView reloadData];

    self.databaseTableView.delegate = self;
    self.databaseTableView.dataSource = self;
    self.databaseTableView.target = self;
    // single click
    [self.databaseTableView setAction:@selector(selectChannelRowAction:)];
}

- (void)reloadChannelsListFromDB {
    _allFeedChannels = [self.dbUtil getAllChannelsOfUserDB];
//    [self.databaseTableView reloadData];
}

- (void)reloadChannelInfoFromDB:(RSSChannelElement *)element {
    RSSChannelElement *temp = [self.dbUtil getChannelFromUserDB:element.feedURL.absoluteString];
    if (temp != nil) {
        element = temp;
    }
    [self showChannelElementOnTableView:element];
}

- (void)showDatabaseChannelItemsAt:(NSUInteger)index {
    [self showChannelElementOnTableView:self.allFeedChannels[index]];
}

- (void)showChannelElementOnTableView:(RSSChannelElement *)element {
    _channelElementToShow = element;
    if (self.channelElementToShow != nil) {
        if (self.channelElementToShow.feedURL.absoluteString != nil) {
            [_feedUrlTextField setStringValue:self.channelElementToShow.feedURL.absoluteString];
        }
        if (self.channelElementToShow.languageOfChannel != nil) {
            [_channelLanguageTextField setStringValue:self.channelElementToShow.languageOfChannel];
        }

        NSImage *favicon = [[NSImage alloc] initWithData:self.channelElementToShow.favIconData];

        // resize favicon
        CGFloat scale = MIN(_channelFavIconImageView.bounds.size.width / favicon.size.width, _channelFavIconImageView.bounds.size.height / favicon.size.height);
        favicon.size = NSMakeSize(favicon.size.width * scale, favicon.size.height * scale);

        [_channelFavIconImageView.cell setImage:favicon];

        if (_useHTMLLabelCheckBox.state == 0) {
            [_channelTitleTextField setStringValue:self.channelElementToShow.titleOfElement];
            [_channelDescriptionTextField setStringValue:self.channelElementToShow.descriptionOfElement];
        } else {
            NSAttributedString *attributedStringTitle = [[NSAttributedString alloc]
                    initWithData:[self.channelElementToShow.titleOfElement dataUsingEncoding:NSUnicodeStringEncoding]
                         options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType}
              documentAttributes:nil
                           error:nil];
            [_channelTitleTextField setAttributedStringValue:attributedStringTitle];
            NSAttributedString *attributedStringDescription = [[NSAttributedString alloc]
                    initWithData:[self.channelElementToShow.descriptionOfElement dataUsingEncoding:NSUnicodeStringEncoding]
                         options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType}
              documentAttributes:nil
                           error:nil];
            [_channelDescriptionTextField setAttributedStringValue:attributedStringDescription];
        }
        NSString *dataString = [self.channelElementToShow.pubDateOfElement convertToString];
        if (dataString != nil) {
            [_channelPubDateTextField setStringValue:dataString];
        }

        [self.feedItemsTableView reloadData];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)startParserWithString:(NSString *)inputString {
    // delete whiteSpace and new line.
    NSString *urlString = [inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([urlString isEqualToString:@""]) {
        return;
    }

    NSURL *feedURL = [NSURL URLWithString:urlString];
    [self startParserWithURL:feedURL];
}

- (void)startParserWithURL:(NSURL *)feedURL {
//    NSError *urlError = nil;
//    _feedParser = [[FeedParser alloc] initWithURL:feedURL];
//    [_feedParser startRequestSync:&urlError];
//    _feedParser.delegate = self;
//    NSLog(@"initWithURL error is %@", urlError);
//    _data = [_feedParser.xmlData copy];
//
//    [_startParseButton setEnabled:(_data != nil)];

    _feedParser = [[FeedParser alloc] initWithURL:feedURL];
    _feedParser.delegate = self;
    __weak FeedParser *weakSelf = self.feedParser;
    self.reloadFeedButton.title = RELOAD_STOP_LABEL;
    [self.feedParser startRequestAsync:^(NSError *error) {
        if (error == nil) {
            [weakSelf startParser];
        } else {
            [self parseCompleted:NO];
        }
    }];
}

- (IBAction)addUrlButtonPressed:(NSButton *)sender {
    if (self.urlSheetDelegate != nil) {
        [self.urlSheetDelegate beginOpenUrlSheet:^(NSModalResponse returnCode, NSString *resultUrl) {
            NSLog(@"OpenUrlSheet return %ld, %@", returnCode, resultUrl);
            if (returnCode == NSModalResponseOK) {
                [self startParserWithString:resultUrl];
            }
        }];
    }
}

- (IBAction)removeButtonAction:(NSButton *)sender {
    // remove current selected
    NSIndexSet *set = [self.databaseTableView selectedRowIndexes];
    NSUInteger count = set.count;
    NSUInteger selectRow = [set firstIndex];
    if (count == 0) return;
    while (selectRow != NSNotFound) {
        RSSChannelElement *element = self.allFeedChannels[selectRow];
        [self.dbUtil deleteChannelOfUserDB:element];
        selectRow = [set indexGreaterThanIndex:selectRow];
    }

    [self reloadChannelsListFromDB];
    [self.databaseTableView reloadData];

    if ([self.allFeedChannels count] == 0) return;
    // selected first item
    [self selectChannelRowAt:0];
}

- (IBAction)reloadButtonAction:(NSButton *)sender {
    BOOL isReloading = [self.feedParser isWorking];
    if (isReloading) {
        [self stopParser];
    } else {
        // parse current feed, get newest content
        NSIndexSet *set = [self.databaseTableView selectedRowIndexes];
        NSUInteger count = set.count;
        if (count > 0) {
            // reload first channel
            NSUInteger selectRow = [set firstIndex];
            RSSChannelElement *element = self.allFeedChannels[selectRow];
            [self startParserWithURL:element.feedURL];
            // TODO reload all selected channels
            // reloadChannelsListFromDB will called parse completed.
        } else {
            // TODO reload all if select none.
//            for (RSSChannelElement *element in self.allFeedChannels) {
//                [self startParserWithURL:element.feedURL];
//                // reloadChannelsListFromDB will called parse completed.
//            }
        }
    }
}

- (IBAction)openFileButtonPressed:(NSButton *)sender {
    NSLog(@"Button Clicked.");

    NSString *path = [self getFilePathFromDialog];
    // show path in Text Field.
    [_feedUrlTextField setStringValue:(path != nil) ? path : @""];

    if (path != nil) [self clearUIContents];

    _data = [self loadDataFromFile:path];
    _feedParser = [[FeedParser alloc] initWithData:_data];
    _feedParser.delegate = self;
    [self startParse];
}

- (IBAction)didChannelLinkClicked:(NSButton *)sender {
    NSString *urlString = self.channelElementToShow.linkOfElement;
    NSLog(@"didChannelLinkClicked Url: %@", urlString);
    [self openURL:urlString];
}

- (void)openURL:(NSString *)urlString {
    if (urlString != nil && [urlString hasPrefix:@"http://"]) {
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}

- (void)startParse {
    if (_feedParser != nil) {
        [_feedParser stopParser];
    }
    [_feedParser startParserWithStyle:(XMLElementStringStyle) [_elementStringStylePopUp indexOfSelectedItem]
                          parseEngine:(XMLParseEngine) [_parseEnginePopup indexOfSelectedItem]];
}

- (IBAction)stopParser:(NSButton *)sender {
    [self stopParser];
}

- (void)stopParser {
    if (_feedParser != nil) {
        [_feedParser stopParser];
    }
    self.reloadFeedButton.title = RELOAD_START_LABEL;
}

- (NSData *)loadDataFromFile:(NSString *)path {
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    if (data == nil) {
        NSLog(@"loadDataFromFile data is NULL !!!");
    }
    //    NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //    NSLog(@"loadDataFromFile data is %@", strData);
    return data;
}

- (NSString *)getFilePathFromDialog {
    // Create the File Open Dialog class.
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    //    // Enable the selection of files in the dialog.
    //    [openPanel setCanChooseFiles:YES];
    //    // Multiple files not allowed
    //    [openPanel setAllowsMultipleSelection:NO];
    // Can't select a directory
    [openPanel setCanChooseDirectories:NO];
    // set file type.
    [openPanel setAllowedFileTypes:@[@"xml"]];

    NSURL *result = nil;

    // single selection
    if ([openPanel runModal] == NSModalResponseOK) {
        result = [openPanel URLs][0];
    }

    NSLog(@"getFilePathFromDialog Url: %@", result);
    return result.path;
}

- (void)removeAllObjectsOfTable {
    [self.feedItemsTableView reloadData];
}

- (void)clearUIContents {
    [self removeAllObjectsOfTable];
    [_channelTitleTextField setStringValue:@""];
    [_channelDescriptionTextField setStringValue:@""];
    [_channelPubDateTextField setStringValue:@""];
    [_channelLanguageTextField setStringValue:@""];
}

#pragma mark - FeedParserDelegate

- (void)elementDidParsed:(RSSBaseElement *)element {
    if (element == nil) {
        NSLog(@"elementDidParsed receive a nil value.");
        return;
    }
    if ([element isKindOfClass:[RSSChannelElement class]]) {
        // local xml file's feedURL is nil.
        BOOL isLocalFile = (element.feedURL == nil);
        if (isLocalFile) {
            [self showChannelElementOnTableView:((RSSChannelElement *) element)];
        } else {
            NSInteger count = [self allFeedChannels].count;
            [self reloadChannelsListFromDB];
            if (count != [self allFeedChannels].count) {
                [self.databaseTableView reloadData];
                [self selectChannelRowAt:[self allFeedChannels].count - 1];
            } else {
                [self reloadChannelInfoFromDB:(RSSChannelElement *) element];
            }
        }
    } else if ([element isKindOfClass:[RSSItemElement class]]) {

    }
}

- (void)allElementsDidParsed {
    NSLog(@"allElementsDidParsed.");
}

- (void)parseCompleted:(BOOL)completed {
    NSLog(@"parseCompleted %d", completed);
    self.reloadFeedButton.title = RELOAD_START_LABEL;
}

#pragma mark - FeedChannelDelegate
- (RSSChannelElement *)getChannelElementToShow {
    return self.channelElementToShow;
}

#pragma mark - NSTableViewDelegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSUInteger unsignedRow = (NSUInteger) row;
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if ([tableColumn.identifier isEqualToString:@"channelColumn"]) {
        RSSChannelElement *element = self.allFeedChannels[unsignedRow];
        [cellView.textField setStringValue:element.titleOfElement];
    }
    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger count = self.allFeedChannels.count;
    return count;
}

- (void)selectChannelRowAt:(NSUInteger)index {
    [self.databaseTableView selectRowIndexes:[[NSIndexSet alloc] initWithIndex:index] byExtendingSelection:NO];
    [self showDatabaseChannelItemsAt:index];
}

- (void)selectChannelRowAction:(NSTableView *)sender {
    NSNumber *rowNumber = @(sender.clickedRow);
    NSLog(@"selectRowAction %ld", rowNumber.integerValue);
    if (rowNumber.integerValue >= 0) {
        [self showDatabaseChannelItemsAt:rowNumber.unsignedIntegerValue];
    } else {
        // -1 means all items are not selected.
    }
}

@end