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
            [self showPopup:[error description] withTitle:@"Error with contacts upload"];
        } else {
            [self findContactMatches];
        }
    }];
}

- (void)findContactMatches {
    DGTSession *userSession = [Digits sharedInstance].session;
    DGTContacts *contacts = [[DGTContacts alloc] initWithUserSession:userSession];
    
    [contacts lookupContactMatchesWithCursor:nil completion:^(NSArray *matches, NSString *nextCursor, NSError *error) {
        if (error) {
            [self showPopup:[error description] withTitle:@"Find friends error"];
        } else if ([matches count] == 0) {
            [self showPopup:@"You have no contacts using this app :(" withTitle:@"No contacts found"];
        }
    }];
}

- (void)showPopup:(NSString *)message withTitle:(NSString *)title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
