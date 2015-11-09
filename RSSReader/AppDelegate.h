//
//  AppDelegate.h
//  RSSReader
//
//  Created by zhangchao on 15/2/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol OpenUrlSheetDelegate <NSObject>
- (void)beginOpenUrlSheet:(void (^)(NSModalResponse returnCode, NSString *resultUrl))handler;
@end

@interface AppDelegate : NSObject <NSApplicationDelegate, OpenUrlSheetDelegate>
@property (weak) IBOutlet NSView *targetView;

@end