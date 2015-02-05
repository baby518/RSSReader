//
//  ViewController.h
//  RSSReader
//
//  Created by zhangchao on 15/2/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XMLParser.h"

@interface ViewController : NSViewController
@property (nonatomic, strong, readonly) NSData *data;

@property (weak) IBOutlet NSTextField *filePathTextField;
@property (weak) IBOutlet NSButton *startParseButton;

- (IBAction)openFileButtonPressed:(NSButton *)sender;
- (IBAction)startParserButtonPressed:(NSButton *)sender;
- (void) startParseData:(NSData *)data;

- (NSString *)getFilePathFromDialog;
- (NSData *)loadDataFromFile:(NSString *)path;

//- (void)removeAllObjectsOfTable;
- (void)clearUIContents;

@end

