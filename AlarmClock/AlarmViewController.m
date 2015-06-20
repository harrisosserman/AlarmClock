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
#import <AVFoundation/AVFoundation.h>

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
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) PFObject *wakeTime;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
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
            self.wakeTime = wakeTime;
        } else if(error) {
            self.tomorrowAlarmTime.text = @"Not Set Yet";
        }
    }];
    NSString *path = [NSString stringWithFormat:@"%@/AOS04836_Antique_Alarm_Bell_Long.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
//    NSURL *soundUrl = [NSURL fileURLWithPath:@"Sounds/AOS04836_Antique_Alarm_Bell_Long.mp3"];
    NSError *audioError;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&audioError];
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

- (void)endBackgroundTask {
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
    self.backgroundTask = UIBackgroundTaskInvalid;
}

- (void)setAlarmBackgroundTask {
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDate *now = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *alarmTimeComponents = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay) fromDate:now];
        [alarmTimeComponents setHour: [Helpers convertToMilitaryTime:self.wakeTime]];
        [alarmTimeComponents setMinute:[self.wakeTime[@"minute"] integerValue]];
        if ([[gregorian dateFromComponents:alarmTimeComponents] compare:now] != NSOrderedDescending) {
            [alarmTimeComponents setDay: [alarmTimeComponents day] + 1];
        }
        NSDate *alarmTime = [gregorian dateFromComponents:alarmTimeComponents];
        
        NSTimeInterval interval = [alarmTime timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
        
        [NSTimer scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(playAlarm)
                                       userInfo:nil
                                        repeats:NO];
    });
}

- (void)playAlarm {
    [self endBackgroundTask];
    [self.audioPlayer play];
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
                self.wakeTime = userWakeTime;
            }];
            [self.friendAlarms reloadData];
        } else {
            NSLog(@"there was an error authenticating with digits");
        }
    }];
    [self updateTomorrowAlarmTime];
    [self endBackgroundTask];
    [self setAlarmBackgroundTask];
}

@end
