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
    //    for now, this just returns all other alarm time objects
    if ([[Digits sharedInstance] session] == nil) {
        return nil;
    }
    __block NSArray *alarmTimes;
    NSError *queryError;
    PFQuery *query = [PFQuery queryWithClassName:@"AlarmTime"];
    [query whereKey:@"phone_number" notEqualTo:[[[Digits sharedInstance] session] phoneNumber]];
    NSArray *wakeTimes = [query findObjects:&queryError];
    if (wakeTimes) {
        alarmTimes = wakeTimes;
    } else if(queryError) {
        alarmTimes = nil;
    }
    return alarmTimes;
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
