//
//  RSSBaseElement.m
//  RSSReader
//
//  Created by zhangchao on 15/2/10.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "RSSBaseElement.h"
#import "RSSSchema.h"
#import "AtomSchema.h"

@implementation RSSBaseElement

- (instancetype)init {
    return [self initWithTitle:@""];
}

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.titleOfElement = title;
        self.linkOfElement = @"";
        self.descriptionOfElement = @"";
        self.pubDateStringOfElement = @"";
    }
    return self;
}

- (void)setPubDateStringOfElement:(NSString *)pubDateStringOfElement {
    _pubDateStringOfElement = pubDateStringOfElement;
    if (_pubDateStringOfElement != nil) {
        _pubDateOfElement = [RSSSchema convertString2Date:_pubDateStringOfElement];
        if (_pubDateOfElement == nil) {
            _pubDateOfElement = [AtomSchema convertString2Date:_pubDateStringOfElement];
        }
    }
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@:", NSStringFromClass([self class])];
    [description appendFormat:@"  titleOfElement=%@", self.titleOfElement];
    [description appendFormat:@", linkOfElement=%@", self.linkOfElement];
    [description appendFormat:@", pubDateOfElement=%@", self.pubDateOfElement];
    [description appendFormat:@", descriptionOfElement=%@", self.descriptionOfElement];
    [description appendString:@">"];
    return description;
}

@end
