//
//  RSSBaseElement.h
//  RSSReader
//
//  Created by zhangchao on 15/2/10.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSBaseElement : NSObject

@property(nonatomic, strong) NSString *titleOfElement;
@property(nonatomic, strong) NSString *linkOfElement;
@property(nonatomic, strong) NSString *descriptionOfElement;
@property(nonatomic, strong) NSString *pubDateStringOfElement;
@property(nonatomic, strong) NSDate *pubDateOfElement;
@property(nonatomic, strong) NSString *categoryOfElement;
@property(nonatomic, strong) NSString *favIconURL;
@property(nonatomic, strong) NSData *favIconData;
@property(nonatomic, strong) NSMutableArray *imageUrlArray;
// channel's feed url
@property(nonatomic, strong) NSURL *feedURL;
@property(nonatomic, assign) BOOL starred;

- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)initWithURL:(NSURL *)url;
- (NSString *)description;
@end
