//
//  ViewController.m
//  RSSReader
//
//  Created by zhangchao on 15/2/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "ViewController.h"
#import "NSDate+helper.h"
#import "NSString+helper.h"
#import "BaseFMDBUtil.h"
#import "PresetFMDBUtil.h"
#import "UserFMDBUtil.h"

@interface ViewController ()

@property (nonatomic, strong) PresetFMDBUtil *presetDB;
@property (nonatomic, strong) UserFMDBUtil *userDB;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _numberOfRows = 0;

    [_xmlSourcePopup addItemsWithTitles:XMLSourceArrays];
    [_elementStringStylePopUp addItemsWithTitles:XMLElementStringStyleArrays];
    [_parseEnginePopup addItemsWithTitles:XMLParseEngineArrays];
    // Do any additional setup after loading the view.
    XMLSource source = (XMLSource) [_xmlSourcePopup indexOfSelectedItem];
    [self checkXmlSourceChoose:source];

    self.feedItemsTableView.delegate = self;
    self.feedItemsTableView.dataSource = self;
    
    [self initFMDB];
}

- (void)initFMDB {
    _presetDB = [PresetFMDBUtil getInstance];
//    if (self.presetDB != nil) {
//        NSArray *categoryArray = [self.presetDB getAllCategories];
//        for (NSString *category in categoryArray) {
//            NSLog(@"presetDB categoryArray : %@", category);
//        };
//    }

    _userDB = [UserFMDBUtil getInstance];
//    if (self.userDB != nil) {
//        NSArray *categoryArray = [self.userDB getAllCategories];
//        for (NSString *category in categoryArray) {
//            NSLog(@"userDB categoryArray : %@", category);
//        };
//    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)checkXmlSourceChoose:(XMLSource)source {
    NSLog(@"checkXmlSourceChoose index : %d", (int) [_xmlSourcePopup indexOfSelectedItem]);
    if (source == XMLSourceLocalFile) {
        // disable sth.
        [self.loadUrlButton setEnabled:NO];
        [self.openLocalFileButton setEnabled:YES];
        [self.filePathTextField setEditable:NO];
        [self.filePathTextField setStringValue:@""];
    } else if (source == XMLSourceURL) {
        // disable sth.
        [self.openLocalFileButton setEnabled:NO];
        [self.loadUrlButton setEnabled:YES];
        [self.filePathTextField setEditable:YES];
        [self.filePathTextField setStringValue:@"http://rss.cnbeta.com/rss"];
//        [self.filePathTextField setStringValue:@"http://192.168.2.2/qq_web_2312.xml"];
    }
}

- (IBAction)loadUrlButtonPressed:(NSButton *)sender {
    // TODO load Feed data and save data in self.data
    // delete whiteSpace and new line.
    NSString *urlString = [self.filePathTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // TODO just for test ++++++
    // check it in preset database.
    if (self.presetDB != nil) {
    }

//    if (self.userDB != nil) {
//        RSSChannelElement *result = [self.userDB getChannelFromURL:@"http://www.ithome.com/rss"];
//        if (result != nil) {
//            NSLog(@"query result %@", result.description);
//        }
//    }
    // just for test ------

    [self startParserWithURL:urlString];
}

- (void)startParserWithURL:(NSString *)urlString {
    NSURL *feedURL = [NSURL URLWithString:urlString];

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
    [self.feedParser startRequestAsync:^(NSError *error) {
        if (error == nil) {
            [weakSelf startParser];
        } else {
            [self parseCompleted:NO];
        }
    }];
}

- (IBAction)didXmlSourceChoose:(NSPopUpButton *)sender {
    XMLSource source = (XMLSource) [_xmlSourcePopup indexOfSelectedItem];
    [self checkXmlSourceChoose:source];
}

- (IBAction)openFileButtonPressed:(NSButton *)sender {
    NSLog(@"Button CLicked.");
    
    NSString *path = [self getFilePathFromDialog];
    // show path in Text Field.
    [_filePathTextField setStringValue:(path != nil) ? path : @""];
    if (path != nil) [self clearUIContents];
    
    _data = [self loadDataFromFile:path];
    _feedParser = [[FeedParser alloc] initWithData:_data];
    _feedParser.delegate = self;
    [self startParse];
}

- (IBAction)didChannelLinkClicked:(NSButton *)sender {
    NSString *urlString = [_channelLinkButton accessibilityValueDescription];
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
    if (_feedParser != nil) {
        [_feedParser stopParser];
    }
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
//    [_currentTrackPoints removeAllObjects];
    _numberOfRows = 0;
    [self.feedItemsTableView reloadData];
}

- (void)clearUIContents {
    [self removeAllObjectsOfTable];
    [_channelTitleTextField setStringValue:@""];
    [_channelLinkTextField setStringValue:@""];
    [_channelLinkButton setAccessibilityValueDescription:@""];
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
        [_channelLinkTextField setStringValue:element.linkOfElement];
        [_channelLinkButton setAccessibilityValueDescription:element.linkOfElement];
        [_channelLanguageTextField setStringValue:((RSSChannelElement *)element).languageOfChannel];
        [_channelFavIconImageView setImage:[[NSImage alloc] initWithData:element.favIconData]];

        if (_useHTMLLabelCheckBox.state == 0) {
            [_channelTitleTextField setStringValue:element.titleOfElement];
            [_channelDescriptionTextField setStringValue:element.descriptionOfElement];
        } else {
            NSAttributedString *attributedStringTitle = [[NSAttributedString alloc]
                    initWithData:[element.titleOfElement dataUsingEncoding:NSUnicodeStringEncoding]
                         options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType}
              documentAttributes:nil
                           error:nil];
            [_channelTitleTextField setAttributedStringValue:attributedStringTitle];
            NSAttributedString *attributedStringDescription = [[NSAttributedString alloc]
                    initWithData:[element.descriptionOfElement dataUsingEncoding:NSUnicodeStringEncoding]
                         options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType}
              documentAttributes:nil
                           error:nil];
            [_channelDescriptionTextField setAttributedStringValue:attributedStringDescription];
        }
        NSString *dataString = [element.pubDateOfElement convertToString];
        if (dataString != nil) {
            [_channelPubDateTextField setStringValue:dataString];
        }

        _currentChannel = ((RSSChannelElement *) element);
        _numberOfRows = _currentChannel.itemsOfChannel.count;
        NSLog(@"elementDidParsed receive RSSChannelElement. has %ld items", _numberOfRows);

        // add it in user database.
        // maybe it is stored in database already.
        if (self.userDB != nil) {
            [self.userDB updateChannelElement:self.currentChannel];
        }
    } else if ([element isKindOfClass:[RSSItemElement class]]) {

    }
    [self.feedItemsTableView reloadData];
}

- (void)allElementsDidParsed {
    NSLog(@"allElementsDidParsed.");
}

- (void)parseCompleted:(BOOL)completed {
    NSLog(@"parseCompleted %ld", completed);
}


#pragma mark - NSTableViewDelegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSUInteger unsignedRow = (NSUInteger) row;
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];

    if ([tableColumn.identifier isEqualToString:@"ItemID"]) {
        [[cellView textField] setStringValue:[NSString stringWithFormat:@"%ld", unsignedRow + 1]];
    } else if ([tableColumn.identifier isEqualToString:@"ItemDate"]) {
        NSDate *pubDate = ((RSSItemElement *) (_currentChannel.itemsOfChannel[unsignedRow])).pubDateOfElement;
        NSString *dateString = [pubDate convertToString];
        if (dateString != nil) {
            [[cellView textField] setStringValue:dateString];
        }
    } else if ([tableColumn.identifier isEqualToString:@"ItemTitle"]) {
        NSString *title = ((RSSItemElement *) (_currentChannel.itemsOfChannel[unsignedRow])).titleOfElement;
        [[cellView textField] setStringValue:title];
    } else if ([tableColumn.identifier isEqualToString:@"ItemDescription"]) {
        NSString *description = ((RSSItemElement *) (_currentChannel.itemsOfChannel[unsignedRow])).descriptionOfElement;
        [[cellView textField] setStringValue:[NSString removeHTMLLabelAndWhitespace:description maxLength:200]];
    }
    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _numberOfRows;
}
@end