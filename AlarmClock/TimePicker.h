//
//  TimePicker.h
//  AlarmClock
//
//  Created by Harris Osserman on 6/2/15.
//  Copyright (c) 2015 Harris Osserman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimePicker : NSObject<UIPickerViewDataSource, UIPickerViewDelegate>
- (id)initWithHourList:(NSArray *)hourList andhMinuteList:(NSArray *)minuteList andAmpmList:(NSArray *)ampmList;

@end
