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
@property(nonatomic, strong, readonly) NSDate *pubDateOfElement;
@property(nonatomic, strong) NSMutableArray *imageUrlArray;

- (instancetype)initWithTitle:(NSString *)title;
- (NSString *)description;
@end
