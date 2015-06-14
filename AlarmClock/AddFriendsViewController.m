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
#import "AddFriendTableCellView.h"

@interface AddFriendsViewController()
@property (weak, nonatomic) IBOutlet UITableView *potentialFriendsTableView;
@property (strong, nonatomic) NSArray *potentialFriends;
@property (strong, nonatomic) NSMutableArray *currentFriends;
@property (strong, nonatomic) PFObject *userFriendsParseObject;
@end

@implementation AddFriendsViewController


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.potentialFriends = [[NSArray alloc] init];
        self.currentFriends = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    self.potentialFriendsTableView.dataSource = self;
    self.potentialFriendsTableView.delegate = self;
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
            self.potentialFriends = objects;
            [self.potentialFriendsTableView reloadData];
        }
    }];
    PFQuery *friendQuery = [PFQuery queryWithClassName:@"Friends"];
    [friendQuery whereKey:@"phone_number" equalTo:[[[Digits sharedInstance] session] phoneNumber]];
    [friendQuery getFirstObjectInBackgroundWithBlock:^(PFObject *userFriends, NSError *error) {
        if (userFriends) {
            [self.currentFriends addObjectsFromArray:(NSArray *)userFriends[@"friends"]];
            self.userFriendsParseObject = userFriends;
        } else if(error.code != 101) {
//            error code 101 means that the user has no friends
            [self showPopup:[error description] withTitle:@"Error querying potential friends"];
        } else {
            userFriends = [PFObject objectWithClassName:@"Friends"];
            userFriends[@"phone_number"] = [[[Digits sharedInstance] session] phoneNumber];
            userFriends[@"friends"] = @[];
            self.userFriendsParseObject = userFriends;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *potentialFriendTableCell = @"potentialFriendTableCell";
    AddFriendTableCellView *cell = [tableView dequeueReusableCellWithIdentifier:potentialFriendTableCell];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"AddFriendTableCellView" bundle:nil] forCellReuseIdentifier:@"potentialFriendTableCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"potentialFriendTableCell"];
    }
    [cell setPhoneNumber:self.potentialFriends[indexPath.row][@"phone_number"]];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.potentialFriends count];
}

- (void)addFriend:(NSString *)phoneNumber {
    [self.currentFriends addObject:phoneNumber];
    self.userFriendsParseObject[@"friends"] = [self.currentFriends copy];
    [self.userFriendsParseObject saveInBackground];
}


@end
