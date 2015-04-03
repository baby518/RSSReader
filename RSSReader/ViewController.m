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
    [_xmlSourcePopup addItemsWithTitles:XMLSourceArrays];
    [_elementStringStylePopUp addItemsWithTitles:XMLElementStringStyleArrays];
    [_parseEnginePopup addItemsWithTitles:XMLParseEngineArrays];
    // Do any additional setup after loading the view.
    XMLSource source = (XMLSource) [_xmlSourcePopup indexOfSelectedItem];
    [self checkXmlSourceChoose:source];
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
    }
}

- (IBAction)loadUrlButtonPressed:(NSButton *)sender {
    // TODO load Feed data and save data in self.data
    // delete whiteSpace and new line.
    NSString *urlString = [self.filePathTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *feedURL = [NSURL URLWithString:urlString];

    NSError *urlError = nil;
    _feedParser = [[FeedParser alloc] initWithURL:feedURL error:&urlError];
    NSLog(@"initWithURL error is %@", urlError);
    _data = [_feedParser.xmlData copy];

    [_startParseButton setEnabled:(_data != nil)];
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
        if (_feedParser != nil) {
            [_feedParser stopParser];
            _feedParser = nil;
        }
        _feedParser = [[FeedParser alloc] initWithData:data];
        _feedParser.delegate = self;
        [_feedParser startParserWithStyle:(XMLElementStringStyle) [_elementStringStylePopUp indexOfSelectedItem]
                              parseEngine:(XMLParseEngine) [_parseEnginePopup indexOfSelectedItem]];
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
    [_channelLanguageTextField setStringValue:@""];
}

#pragma mark - XMLParserDelegate

- (void)elementDidParsed:(RSSBaseElement *)element {
    if (element == nil) {
        NSLog(@"elementDidParsed receive a nil value.");
        return;
    }
    if ([element isKindOfClass:[RSSChannelElement class]]) {
        [_channelLinkTextField setStringValue:element.linkOfElement];
        [_channelLinkButton setAccessibilityValueDescription:element.linkOfElement];
        [_channelLanguageTextField setStringValue:((RSSChannelElement *)element).languageOfChannel];

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
        [_channelPubDateTextField setStringValue:[RSSSchema convertDate2String:element.pubDateOfElement]];
    } else if ([element isKindOfClass:[RSSItemElement class]]) {

    }
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
