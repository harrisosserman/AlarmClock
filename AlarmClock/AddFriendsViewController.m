//
//  AddFriendsViewController.m
//  AlarmClock
//
//  Created by Harris Osserman on 6/3/15.
//  Copyright (c) 2015 Harris Osserman. All rights reserved.
//

#import "AddFriendsViewController.h"

@implementation AddFriendsViewController

- (void)viewDidLoad {
    DGTSession *userSession = [Digits sharedInstance].session;
    DGTContacts *contacts = [[DGTContacts alloc] initWithUserSession:userSession];
    
    [contacts startContactsUploadWithCompletion:^(DGTContactsUploadResult *result, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error with contacts upload"
                                                            message:error.description
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

@end
