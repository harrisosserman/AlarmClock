//
//  ViewController.m
//  AlarmClock
//
//  Created by Harris Osserman on 5/22/15.
//  Copyright (c) 2015 Harris Osserman. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import <DigitsKit/DigitsKit.h>
#import "TimePicker.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *timePicker;
@property (strong, nonatomic) NSArray *hourList;
@property (strong, nonatomic) NSArray *minuteList;
@property (strong, nonatomic) NSArray *ampmList;
@property (weak, nonatomic) IBOutlet UILabel *tomorrowAlarmTime;
@property (weak, nonatomic) IBOutlet UITableView *friendAlarms;
@property (strong, nonatomic) TimePicker *timePickerDelegate;
@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hourList = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];
        self.minuteList = [[NSArray alloc] initWithObjects:@"00", @"05", @"10", @"15", @"20", @"25", @"30", @"35", @"40", @"45", @"50", @"55", nil];
        self.ampmList = [[NSArray alloc] initWithObjects:@"AM", @"PM", nil];
        self.timePickerDelegate = [[TimePicker alloc] initWithHourList:self.hourList andhMinuteList:self.minuteList andAmpmList:self.ampmList];
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
    self.friendAlarms.delegate = self;
    self.friendAlarms.dataSource = self;
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
