//
//  TimePicker.m
//  AlarmClock
//
//  Created by Harris Osserman on 6/2/15.
//  Copyright (c) 2015 Harris Osserman. All rights reserved.
//

#import "TimePicker.h"

@interface TimePicker()
@property (nonatomic, strong) NSArray *hourList;
@property (nonatomic, strong) NSArray *minuteList;
@property (nonatomic, strong) NSArray *ampmList;
@end


@implementation TimePicker

- (id)initWithHourList:(NSArray *)hourList andhMinuteList:(NSArray *)minuteList andAmpmList:(NSArray *)ampmList {
    self = [super init];
    if (self) {
        _hourList = hourList;
        _minuteList = minuteList;
        _ampmList = ampmList;
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

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

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
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

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        

    }
    // Fill the label text here
    return tView;
}

@end
