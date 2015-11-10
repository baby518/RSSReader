//
//  ViewController.m
//  RSSReader
//
//  Created by zhangchao on 15/2/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "ViewController.h"
#import "NSDate+helper.h"
#import "BaseFMDBUtil.h"
#import "PresetFMDBUtil.h"
#import "UserFMDBUtil.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (nonatomic, strong) PresetFMDBUtil *presetDB;
@property (nonatomic, strong) UserFMDBUtil *userDB;
@property (weak) IBOutlet NSTableView *databaseTable;
@property (nonatomic, strong) FeedItemTableDelegate *feedItemTableDelegate;
@end

@implementation ViewController

/** use viewDidLoad on OSX 10.10 + */
- (void)loadView {
    [super loadView];
    
    _numberOfRows = 0;

    [_elementStringStylePopUp addItemsWithTitles:XMLElementStringStyleArrays];
    [_parseEnginePopup addItemsWithTitles:XMLParseEngineArrays];

    [self initTabContent];

    _feedItemTableDelegate = [[FeedItemTableDelegate alloc] initWithChannelDelegate:self];
    NSLog(@"----- initWithChannelElement : %@", self.currentChannel);
    self.feedItemsTableView.delegate = self.feedItemTableDelegate;
    self.feedItemsTableView.dataSource = self.feedItemTableDelegate;

    [self initFMDB];
}

- (void)initFMDB {
    _userDB = [UserFMDBUtil getInstance];
    if (self.userDB != nil) {
        NSArray *categoryArray = [self.userDB getAllCategories];
        for (NSString *category in categoryArray) {
            NSLog(@"userDB categoryArray : %@", category);
        };
    }
    [_userDB closeDB];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)initTabContent {
    // local tab
    [self.openLocalFileButton setEnabled:YES];
    
    // web tab
    [self.loadWebUrlButton setEnabled:YES];
}

- (void)startParserWithString:(NSString *)inputString {
    // delete whiteSpace and new line.
    NSString *urlString = [inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([urlString isEqualToString:@""]) {
        return;
    }

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

    [_feedUrlTextField setStringValue:(feedURL != nil) ? feedURL.absoluteString : @""];

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

- (IBAction)loadUrlButtonPressed:(NSButton *)sender {
    if (self.urlSheetDelegate != nil) {
        [self.urlSheetDelegate beginOpenUrlSheet:^(NSModalResponse returnCode, NSString *resultUrl) {
            NSLog(@"OpenUrlSheet return %ld, %@", returnCode, resultUrl);
            if (returnCode == NSModalResponseOK) {
                [self startParserWithString:resultUrl];
            }
        }];
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
    NSString *urlString = self.currentChannel.linkOfElement;
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
        // search it in preset database first
        _presetDB = [PresetFMDBUtil getInstance];
        if (self.presetDB != nil) {
            RSSChannelElement *temp = [self.presetDB getChannelFromURL:element.feedURL.absoluteString];
            if (temp != nil) {
                element.categoryOfElement = temp.categoryOfElement;
                if (temp.favIconData != nil) {
                    element.favIconData = temp.favIconData;
                }
            }
        }
        [_presetDB closeDB];

        [_channelLinkTextField setStringValue:element.linkOfElement];
        [_channelLanguageTextField setStringValue:((RSSChannelElement *) element).languageOfChannel];

        NSImage *favicon = [[NSImage alloc] initWithData:element.favIconData];

        // resize favicon
        CGFloat scale = MIN(_channelFavIconImageView.bounds.size.width / favicon.size.width, _channelFavIconImageView.bounds.size.height / favicon.size.height);
        favicon.size = NSMakeSize(favicon.size.width * scale, favicon.size.height * scale);

        [_channelFavIconImageView.cell setImage:favicon];

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
        _userDB = [UserFMDBUtil getInstance];
        if (self.userDB != nil) {
            [self.userDB updateChannelElement:self.currentChannel];
        }
        [_userDB closeDB];
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

#pragma mark - FeedChannelDelegate
- (RSSChannelElement *)getChannelElement {
    return self.currentChannel;
}
@end