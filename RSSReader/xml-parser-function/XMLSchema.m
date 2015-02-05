//
// Created by zhangchao on 14/10/26.
// Copyright (c) 2014 zhangchao. All rights reserved.
//

#import "XMLSchema.h"

NSString *const XML_NAMESPACE                   = @"xmlns";
NSString *const XML_NAMESPACE_STRING            = @"http://www.topografix.com/GPX/1/1";
NSString *const XML_NAMESPACE_XSI               = @"xmlns:xsi";
NSString *const XML_NAMESPACE_XSI_STRING        = @"http://www.w3.org/2001/XMLSchema-instance";
NSString *const XML_NAMESPACE_SCHEMA            = @"xsi:schemaLocation";
NSString *const XML_NAMESPACE_SCHEMA_STRING     = @"http://www.topografix.com/GPX/1/1/gpx.xsd";

NSString *const ROOT_NAME                       = @"rss";
NSString *const ATTRIBUTE_ROOT_VERSION          = @"version";

NSString *const ELEMENT_CHANNEL                 = @"channel";
NSString *const ELEMENT_CHANNEL_TITLE           = @"title";
NSString *const ELEMENT_CHANNEL_LINK            = @"link";
NSString *const ELEMENT_CHANNEL_DESCRIPTION     = @"description";
NSString *const ELEMENT_CHANNEL_PUBDATE         = @"pubDate";
NSString *const ELEMENT_CHANNEL_LANGUAGE        = @"language";
NSString *const ELEMENT_CHANNEL_COPYRIGHT       = @"copyright";

NSString *const ELEMENT_ITEM                    = @"item";
NSString *const ELEMENT_ITEM_TITLE              = @"title";
NSString *const ELEMENT_ITEM_LINK               = @"link";
NSString *const ELEMENT_ITEM_DESCRIPTION        = @"description";
NSString *const ELEMENT_ITEM_PUBDATE            = @"pubDate";
NSString *const ELEMENT_ITEM_DC_CREATOR         = @"dc:creator";

int const MAX_ELEMENT_COUNTS_OF_TRACK           = 100;

@implementation XMLSchema

@end