//
//  FriendList.m
//  AlarmClock
//
//  Created by Harris Osserman on 6/2/15.
//  Copyright (c) 2015 Harris Osserman. All rights reserved.
//

#import "FriendList.h"

@implementation FriendList

- (NSArray *)findFriendAlarmTimes {
    if ([[Digits sharedInstance] session] == nil) {
        return nil;
    }
    NSError *queryError;
    PFQuery *query = [PFQuery queryWithClassName:@"Friends"];
    [query whereKey:@"phone_number" equalTo:[[[Digits sharedInstance] session] phoneNumber]];
    PFObject *queryResult = [query getFirstObject:&queryError];
    if (queryError) {
        return nil;
    } else if (!queryResult) {
        return nil;
    }
    NSMutableArray *friends = [[NSMutableArray alloc] init];
    query = [PFQuery queryWithClassName:@"AlarmTime"];
    for (NSString *phoneNumber in queryResult[@"friends"]) {
        [query whereKey:@"phone_number" equalTo:phoneNumber];
        queryResult = [query getFirstObject:&queryError];
        if (queryResult) {
            [friends addObject:queryResult];
        }
    }
    
    return friends;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *friendAlarmTimes = [self findFriendAlarmTimes];
    return (friendAlarmTimes != nil) ? [friendAlarmTimes count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *friendTableCell = @"friendTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:friendTableCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendTableCell];
    }
    NSArray *friendAlarmTimes = [self findFriendAlarmTimes];
    PFObject *alarmTime = (PFObject *)friendAlarmTimes[indexPath.row];
    NSString *alarmTimeString = [NSString stringWithFormat:@"%@ %@:%@ %@", alarmTime[@"phone_number"], alarmTime[@"hour"], alarmTime[@"minute"], alarmTime[@"ampm"]];
    cell.textLabel.text = alarmTimeString;
    return cell;
}

@end
