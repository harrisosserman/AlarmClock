//
//  ViewController.m
//  AlarmClock
//
//  Created by Harris Osserman on 5/22/15.
//  Copyright (c) 2015 Harris Osserman. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *timePicker;
@property (strong, nonatomic) NSArray *hourList;
@property (strong, nonatomic) NSArray *minuteList;
@property (strong, nonatomic) NSArray *ampmList;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hourList = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];
        self.minuteList = [[NSArray alloc] initWithObjects:@"00", @"05", @"10", @"15", @"20", @"25", @"30", @"35", @"40", @"45", @"50", @"55", nil];
        self.ampmList = [[NSArray alloc] initWithObjects:@"AM", @"PM", nil];
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
    self.timePicker.delegate = self;
    self.timePicker.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0) {
        return 12;
    }
    else if(component == 1) {
        return 12;
    }
    else if(component == 2) {
        return 2;
    }
    return 0;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0) {
        return self.hourList[row];
    }
    else if (component == 1) {
        return self.minuteList[row];
        
    } else if(component == 2) {
        return self.ampmList[row];
    }
    return @"";
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 50.f;
}
- (IBAction)submitButton:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"AlarmTime"];
    [query whereKey:@"phone_number" equalTo:@"1234567890"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *userWakeTime, NSError *error) {
        if (userWakeTime) {
            userWakeTime[@"hour"] = self.hourList[[self.timePicker selectedRowInComponent:0]];
            userWakeTime[@"minute"] = self.minuteList[[self.timePicker selectedRowInComponent:1]];
            userWakeTime[@"ampm"] = self.ampmList[[self.timePicker selectedRowInComponent:2]];
            [userWakeTime saveInBackground];
        } else if(error) {
            PFObject *userWakeTime = [PFObject objectWithClassName:@"AlarmTime"];
            userWakeTime[@"hour"] = self.hourList[[self.timePicker selectedRowInComponent:0]];
            userWakeTime[@"minute"] = self.minuteList[[self.timePicker selectedRowInComponent:1]];
            userWakeTime[@"ampm"] = self.ampmList[[self.timePicker selectedRowInComponent:2]];
            userWakeTime[@"phone_number"] = @"1234567890";
            [userWakeTime saveInBackground];
        }
    }];
}

@end
