//
// Created by zhangchao on 14/10/26.
// Copyright (c) 2014 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const XML_NAMESPACE;
extern NSString *const XML_NAMESPACE_STRING;
extern NSString *const XML_NAMESPACE_XSI;
extern NSString *const XML_NAMESPACE_XSI_STRING;
extern NSString *const XML_NAMESPACE_SCHEMA;
extern NSString *const XML_NAMESPACE_SCHEMA_STRING;

extern NSString *const ROOT_NAME;
extern NSString *const ATTRIBUTE_ROOT_VERSION;

extern NSString *const ELEMENT_CHANNEL;
extern NSString *const ELEMENT_CHANNEL_TITLE;
extern NSString *const ELEMENT_CHANNEL_LINK;
extern NSString *const ELEMENT_CHANNEL_DESCRIPTION;
extern NSString *const ELEMENT_CHANNEL_PUBDATE;
extern NSString *const ELEMENT_CHANNEL_LANGUAGE;
extern NSString *const ELEMENT_CHANNEL_COPYRIGHT;

extern NSString *const ELEMENT_ITEM;
extern NSString *const ELEMENT_ITEM_TITLE;
extern NSString *const ELEMENT_ITEM_LINK;
extern NSString *const ELEMENT_ITEM_DESCRIPTION;
extern NSString *const ELEMENT_ITEM_PUBDATE;
extern NSString *const ELEMENT_ITEM_DC_CREATOR;

extern int const MAX_ELEMENT_COUNTS_OF_TRACK;

@interface XMLSchema : NSObject {
}

@end
