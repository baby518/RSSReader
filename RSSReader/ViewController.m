//
//  ViewController.m
//  RSSReader
//
//  Created by zhangchao on 15/2/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_startParseButton setEnabled:false];
    [_parseModePopUp addItemsWithTitles:XMLParseModeArrays];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)openFileButtonPressed:(NSButton *)sender {
    NSLog(@"Button CLicked.");
    
    NSString *path = [self getFilePathFromDialog];
    // show path in Text Field.
    [_filePathTextField setStringValue:(path != nil) ? path : @""];
    if (path != nil) [self clearUIContents];
    
    _data = [self loadDataFromFile:path];
    [_startParseButton setEnabled:(_data != nil)];
}

- (IBAction)startParserButtonPressed:(NSButton *)sender {
    [self startParseData:_data];
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

- (void) startParseData:(NSData *)data {
    if (data != nil) {
        if (_rssParser != nil) {
            [_rssParser stopParser];
            _rssParser = nil;
        }
        _rssParser = [[RSSParser alloc]initWithData:data];
        _rssParser.delegate = self;
        if ([_parseModePopUp indexOfSelectedItem] == XMLParseModeNormal) {
            [_rssParser startParserWithMode:XMLParseModeNormal];
        } else if ([_parseModePopUp indexOfSelectedItem] == XMLParseModeFilterHtmlLabel) {
            [_rssParser startParserWithMode:XMLParseModeFilterHtmlLabel];
        } else if ([_parseModePopUp indexOfSelectedItem] == XMLParseModeUseHtmlLabel) {
            [_rssParser startParserWithMode:XMLParseModeUseHtmlLabel];
        } else {
            [_rssParser startParserWithMode:XMLParseModeNormal];
        }
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
//    _numberOfRows = 0;
//    [_itemsTableView reloadData];
}

- (void)clearUIContents {
    [self removeAllObjectsOfTable];
    [_channelTitleTextField setStringValue:@""];
    [_channelLinkTextField setStringValue:@""];
    [_channelLinkButton setAccessibilityValueDescription:@""];
    [_channelDescriptionTextField setStringValue:@""];
    [_channelPubDateTextField setStringValue:@""];
}

#pragma mark - XMLParserDelegate

- (void)elementDidParsed:(NSString *)parent key:(NSString *)key value:(NSString *)value {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([parent isEqualToString:ELEMENT_CHANNEL]) {
            if ([key isEqualToString:ELEMENT_CHANNEL_TITLE]) {
                [_channelTitleTextField setStringValue:value];
            } else if ([key isEqualToString:ELEMENT_CHANNEL_LINK]) {
                [_channelLinkTextField setStringValue:value];
                [_channelLinkButton setAccessibilityValueDescription:value];
            } else if ([key isEqualToString:ELEMENT_CHANNEL_DESCRIPTION]) {
                [_channelDescriptionTextField setStringValue:value];
            } else if ([key isEqualToString:ELEMENT_CHANNEL_PUBDATE]) {
                [_channelPubDateTextField setStringValue:
                        [RSSSchema convertDate2String:[RSSSchema convertString2Date:value]]];
            }
        }
    });
}

- (void)elementDidParsed:(NSString *)parent key:(NSString *)key attributedValue:(NSAttributedString *)value {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([parent isEqualToString:ELEMENT_CHANNEL]) {
            if ([key isEqualToString:ELEMENT_CHANNEL_TITLE]) {
                [_channelTitleTextField setAttributedStringValue:value];
            } else if ([key isEqualToString:ELEMENT_CHANNEL_LINK]) {
                [_channelLinkTextField setAttributedStringValue:value];
                [_channelLinkButton setAccessibilityValueDescription:value.string];
            } else if ([key isEqualToString:ELEMENT_CHANNEL_DESCRIPTION]) {
                [_channelDescriptionTextField setAttributedStringValue:value];
            } else if ([key isEqualToString:ELEMENT_CHANNEL_PUBDATE]) {
                [_channelPubDateTextField setStringValue:
                        [RSSSchema convertDate2String:[RSSSchema convertString2Date:value.string]]];
            }
        }
    });
}

//#pragma mark - NSTableViewDelegate
//- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
//    // Get a new ViewCell
//    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
//    return cellView;
//}
//
//- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
//    return _numberOfRows;
//}
@end
