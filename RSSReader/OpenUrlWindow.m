//
//  OpenUrlWindow.m
//  RSSReader
//
//  Created by Apple on 15-11-2.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "OpenUrlWindow.h"

@interface OpenUrlWindow ()
@property (weak) IBOutlet NSTextField *urlInputTextField;
- (IBAction)DoneAction:(NSButton *)sender;
- (IBAction)CancelAction:(NSButton *)sender;
@end

static NSString *defaultFeedURL = @"http://rss.cnbeta.com/rss";

@implementation OpenUrlWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.urlInputTextField setStringValue:defaultFeedURL];
}

- (NSString *)getInputUrl {
    return [self.urlInputTextField stringValue];
}

- (IBAction)DoneAction:(NSButton *)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
    [self.urlInputTextField setStringValue:@""];
}

- (IBAction)CancelAction:(NSButton *)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
    [self.urlInputTextField setStringValue:@""];
}
@end
