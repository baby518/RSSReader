//
//  AppDelegate.m
//  RSSReader
//
//  Created by zhangchao on 15/2/4.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet ViewController *mainViewController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    // 1. Create the master View Controller
    self.mainViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    
    // 2. Add the view controller to the Window's content view
//    [self.window.contentView addSubview:self.mainViewController.view];
//    self.mainViewController.view.frame = ((NSView *) self.window.contentView).bounds;
    [self.window setContentView:self.mainViewController.view];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
