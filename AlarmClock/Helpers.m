//
//  Helpers.m
//  AlarmClock
//
//  Created by Harris Osserman on 6/4/15.
//  Copyright (c) 2015 Harris Osserman. All rights reserved.
//

#import "Helpers.h"

@implementation Helpers

+ (void)saveUserWithPhoneNumber:(NSString *)phoneNumber andUserID:(NSString *)userID {
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"phone_number" equalTo:phoneNumber];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *userObject, NSError *error) {
        if (userObject) {
//            do nothing because the user is already saved
        } else {
            PFObject *userObject = [PFObject objectWithClassName:@"User"];
            userObject = [PFObject objectWithClassName:@"User"];
            userObject[@"userID"] = userID;
            userObject[@"phone_number"] = phoneNumber;
            [userObject saveInBackground];
        }
    }];
}
+ (NSInteger)convertToMilitaryTime:(PFObject *)parseObject {
    NSString *ampm = parseObject[@"ampm"];
    NSInteger hour = [parseObject[@"hour"] integerValue];
    return ([ampm isEqualToString:@"am"] ? hour : 12 + hour);
}
@end
