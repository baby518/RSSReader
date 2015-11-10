//
//  FeedItemTableDataSource.m
//  RSSReader
//
//  Created by Apple on 15-11-9.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "FeedItemTableDelegate.h"
#import "NSDate+helper.h"
#import "NSString+helper.h"

@interface FeedItemTableDelegate ()
@property(nonatomic, weak) id <FeedChannelDelegate> delegate;
@property(nonatomic, assign, readonly) long numberOfRows;
@property(nonatomic, strong, readonly) RSSChannelElement *currentChannel;
@property(nonatomic, assign) BOOL respondsToSelectorGetChannelElement;
@end

@implementation FeedItemTableDelegate
- (id)initWithChannelDelegate:(id <FeedChannelDelegate>)aDelegate {
    self = [super self];
    if (self) {
        _delegate = aDelegate;
        _respondsToSelectorGetChannelElement = [self.delegate respondsToSelector:@selector(getChannelElement)];
    }
    return self;
}

-(RSSChannelElement *)currentChannel {
    if (self.delegate != nil && self.respondsToSelectorGetChannelElement) {
        return [self.delegate getChannelElement];
    }
    return nil;
}

-(long)numberOfRows {
    return self.currentChannel.itemsOfChannel.count;
}

#pragma mark - NSTableViewDelegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSUInteger unsignedRow = (NSUInteger) row;
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];

    if ([tableColumn.identifier isEqualToString:@"ItemID"]) {
        [[cellView textField] setStringValue:[NSString stringWithFormat:@"%ld", unsignedRow + 1]];
    } else if ([tableColumn.identifier isEqualToString:@"ItemDate"]) {
        NSDate *pubDate = ((RSSItemElement *) (self.currentChannel.itemsOfChannel[unsignedRow])).pubDateOfElement;
        NSString *dateString = [pubDate convertToString];
        if (dateString != nil) {
            [[cellView textField] setStringValue:dateString];
        }
    } else if ([tableColumn.identifier isEqualToString:@"ItemTitle"]) {
        NSString *title = ((RSSItemElement *) (self.currentChannel.itemsOfChannel[unsignedRow])).titleOfElement;
        [[cellView textField] setStringValue:title];
    } else if ([tableColumn.identifier isEqualToString:@"ItemDescription"]) {
        NSString *description = ((RSSItemElement *) (self.currentChannel.itemsOfChannel[unsignedRow])).descriptionOfElement;
        [[cellView textField] setStringValue:[NSString removeHTMLLabelAndWhitespace:description maxLength:200]];
    }
    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.numberOfRows;
}
@end
