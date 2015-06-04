//
//  ViewController.m
//  AlarmClock
//
//  Created by Harris Osserman on 5/22/15.
//  Copyright (c) 2015 Harris Osserman. All rights reserved.
//

#import "AlarmViewController.h"
#import <Parse/Parse.h>
#import <DigitsKit/DigitsKit.h>
#import "TimePicker.h"
#import "FriendList.h"
#import "AddFriendsViewController.h"
#import "Helpers.h"

@interface AlarmViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *timePicker;
@property (strong, nonatomic) NSArray *hourList;
@property (strong, nonatomic) NSArray *minuteList;
@property (strong, nonatomic) NSArray *ampmList;
@property (weak, nonatomic) IBOutlet UILabel *tomorrowAlarmTime;
@property (weak, nonatomic) IBOutlet UITableView *friendAlarms;
@property (strong, nonatomic) TimePicker *timePickerDelegate;
@property (strong, nonatomic) FriendList *friendListDelegate;
@property (weak, nonatomic) IBOutlet UIButton *addFriendsButton;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) AddFriendsViewController *addFriendsViewController;
@end

@implementation AlarmViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hourList = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];
        self.minuteList = [[NSArray alloc] initWithObjects:@"00", @"05", @"10", @"15", @"20", @"25", @"30", @"35", @"40", @"45", @"50", @"55", nil];
        self.ampmList = [[NSArray alloc] initWithObjects:@"AM", @"PM", nil];
        self.timePickerDelegate = [[TimePicker alloc] initWithHourList:self.hourList andhMinuteList:self.minuteList andAmpmList:self.ampmList];
        self.friendListDelegate = [[FriendList alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect pickerFrame = self.timePicker.frame;
    pickerFrame.size.width = 150.f;
    [self.timePicker setFrame:pickerFrame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.timePicker.delegate = self.timePickerDelegate;
    self.timePicker.dataSource = self.timePickerDelegate;
    self.friendAlarms.delegate = self.friendListDelegate;
    self.friendAlarms.dataSource = self.friendListDelegate;
    if ([[Digits sharedInstance] session] == nil) {
        self.tomorrowAlarmTime.text = @"Not Set Yet";
        return;
    }
    PFQuery *query = [PFQuery queryWithClassName:@"AlarmTime"];
    [query whereKey:@"phone_number" equalTo:[[[Digits sharedInstance] session] phoneNumber]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *wakeTime, NSError *error) {
        if (wakeTime) {
            self.tomorrowAlarmTime.text = [NSString stringWithFormat:@"%@:%@ %@", wakeTime[@"hour"], wakeTime[@"minute"], wakeTime[@"ampm"]];
        } else if(error) {
            self.tomorrowAlarmTime.text = @"Not Set Yet";
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSDictionary *)getSelectedAlarmTime {
    NSMutableDictionary *returnedValues = [[NSMutableDictionary alloc] init];
    [returnedValues setValue:self.hourList[[self.timePicker selectedRowInComponent:0]] forKey:@"hour"];
    [returnedValues setValue:self.minuteList[[self.timePicker selectedRowInComponent:1]] forKey:@"minute"];
    [returnedValues setValue:self.ampmList[[self.timePicker selectedRowInComponent:2]] forKey:@"ampm"];
    return returnedValues;
}

-(void)populateWithSelectedAlarmTime:(PFObject *)wakeTime {
    NSDictionary *selectedAlarm = [self getSelectedAlarmTime];
    wakeTime[@"hour"] = selectedAlarm[@"hour"];
    wakeTime[@"minute"] = selectedAlarm[@"minute"];
    wakeTime[@"ampm"] = selectedAlarm[@"ampm"];
}

- (void)updateTomorrowAlarmTime {
    NSDictionary *wakeTime = [self getSelectedAlarmTime];
    self.tomorrowAlarmTime.text = [NSString stringWithFormat:@"%@:%@ %@", wakeTime[@"hour"], wakeTime[@"minute"], wakeTime[@"ampm"]];
}

- (IBAction)submitButton:(id)sender {
    __block NSString *phoneNumber = @"";
    [[Digits sharedInstance] authenticateWithCompletion:^(DGTSession* session, NSError *error) {
        if(session) {
            [Helpers saveUserWithPhoneNumber:session.phoneNumber andUserID:session.userID];
            phoneNumber = session.phoneNumber;
            PFQuery *query = [PFQuery queryWithClassName:@"AlarmTime"];
            [query whereKey:@"phone_number" equalTo:phoneNumber];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *userWakeTime, NSError *error) {
                if (userWakeTime) {
                    [self populateWithSelectedAlarmTime:userWakeTime];
                    [userWakeTime saveInBackground];
                } else if(error) {
                    PFObject *userWakeTime = [PFObject objectWithClassName:@"AlarmTime"];
                    [self populateWithSelectedAlarmTime:userWakeTime];
                    userWakeTime[@"phone_number"] = phoneNumber;
                    [userWakeTime saveInBackground];
                }
            }];
            [self.friendAlarms reloadData];
        } else {
            NSLog(@"there was an error authenticating with digits");
        }
    }];
    [self updateTomorrowAlarmTime];
}

@end
