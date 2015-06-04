//
//  AddFriendsViewController.m
//  AlarmClock
//
//  Created by Harris Osserman on 6/3/15.
//  Copyright (c) 2015 Harris Osserman. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "Helpers.h"
#import <Parse/Parse.h>

@implementation AddFriendsViewController

- (void)viewDidLoad {
    [[Digits sharedInstance] authenticateWithCompletion:^(DGTSession* session, NSError *error) {
        if (error) {
            [self showPopup:[error description] withTitle:@"Error logging in"];
        } else {
            [Helpers saveUserWithPhoneNumber:session.phoneNumber andUserID:session.userID];
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
        } else {
            [self populatePotentialFriendsTableWithContacts:matches];
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

- (void)populatePotentialFriendsTableWithContacts:(NSArray *)contacts {
    NSArray *contactUserIDs = [self convertDGTUsersToUserIDs:contacts];
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"userID" containedIn:contactUserIDs];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [self showPopup:[error description] withTitle:@"Error querying potential friends"];
        } else {
            
        }
        
    }];
}

- (NSArray *)convertDGTUsersToUserIDs:(NSArray *)contacts {
    NSMutableArray *userIDs = [[NSMutableArray alloc] initWithCapacity:[contacts count]];
    for (DGTUser *user in contacts) {
        [userIDs addObject:user.userID];
    }
    return userIDs;
}

@end
