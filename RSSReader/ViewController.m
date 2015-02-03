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
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"gpx", @"xml", nil]];
    
    NSURL *result = nil;
    
    // single selection
    if ([openPanel runModal] == NSModalResponseOK) {
        result = [[openPanel URLs] objectAtIndex:0];
    }
    
    NSLog(@"getFilePathFromDialog Url: %@", result);
    
    NSDictionary *properties = [[NSFileManager defaultManager]
                                attributesOfItemAtPath:result.path
                                error:nil];
    NSDate *modDate = properties[NSFileModificationDate];
    NSDate *createDate = properties[NSFileCreationDate];
    
    
    NSLog(@"NSURL modDate: %@", modDate);
    NSLog(@"NSURL createDate: %@", createDate);
    
    NSLog(@"NSURL : %@", result);
    NSLog(@"NSURL path: %@", result.path);
    NSLog(@"NSURL lastPathComponent: %@", result.lastPathComponent);
    NSLog(@"NSURL pathExtension: %@", result.pathExtension);
    NSLog(@"NSURL relativePath: %@", result.relativePath);
    NSLog(@"NSURL relativeString: %@", result.relativeString);
    NSLog(@"NSURL absoluteString: %@", result.absoluteString);
    NSLog(@"NSURL parameterString: %@", result.parameterString);
    return result.path;
}

- (void)clearUIContents {
//    [self removeAllObjectsOfTable];
//    
//    [_mParseStateInfoLabel setStringValue:@""];
//    [_mParserProgress setDoubleValue:0];
//    [_mParserCircleProgress setDoubleValue:0];
//    
//    [_mCreatorTextField setStringValue:@""];
//    [_mVersionTextField setStringValue:@""];
//    [_mLengthTextField setStringValue:@""];
//    [_mTotalTimeTextField setStringValue:@""];
//    [_mElevationGainTextField setStringValue:@""];
}
@end
