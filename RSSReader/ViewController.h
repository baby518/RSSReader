//
//  ViewController.h
//  RSSReader
//
//  Created by zhangchao on 15/2/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (nonatomic, assign, readonly) NSData *data;

@property (weak) IBOutlet NSTextField *filePathTextField;
@property (weak) IBOutlet NSButton *startParseButton;

- (IBAction)openFileButtonPressed:(NSButton *)sender;
- (IBAction)startParserButtonPressed:(NSButton *)sender;

- (NSString *)getFilePathFromDialog;
- (NSData *)loadDataFromFile:(NSString *)path;

//- (void)removeAllObjectsOfTable;
- (void)clearUIContents;

@end

