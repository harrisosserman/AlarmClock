//
//  AddFriendTableCellViewTableViewCell.h
//  AlarmClock
//
//  Created by Harris Osserman on 6/14/15.
//  Copyright (c) 2015 Harris Osserman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddFriendDelegate.h"
@interface AddFriendTableCellView : UITableViewCell
@property (weak, nonatomic) id<AddFriendDelegate> delegate;
@property (nonatomic) NSInteger index;
-(void)setPhoneNumber:(NSString *)phoneNumber;

@end
