//
//  AddFriendTableCellViewTableViewCell.m
//  AlarmClock
//
//  Created by Harris Osserman on 6/14/15.
//  Copyright (c) 2015 Harris Osserman. All rights reserved.
//

#import "AddFriendTableCellView.h"
#import <Parse/Parse.h>

@interface AddFriendTableCellView()
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@end

@implementation AddFriendTableCellView

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setPhoneNumber:(NSString *)phoneNumber {
    self.phoneNumberLabel.text = phoneNumber;
}
- (IBAction)addFriend:(id)sender {
    [self.delegate addFriend:self.phoneNumberLabel.text];
}

@end
