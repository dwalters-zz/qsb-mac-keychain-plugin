//
//  KeychainItemsAction.m
//  KeychainItems
//
//  Created by Dan Walters on 5/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <Vermilion/Vermilion.h>
#import "KeychainItemExt.h"

extern NSString *kKeychainItemKey;

@interface CopyPasswordAction : HGSAction
@end

@implementation CopyPasswordAction
- (BOOL)performWithInfo:(NSDictionary*)info {
  HGSResultArray *directObjects = [info objectForKey:kHGSActionDirectObjectsKey];
  for (HGSResult *result in directObjects) {
    HGSLogDebug(@"copy password action invoked on '%@'", [result displayName]);

    KeychainItem* item = (KeychainItem*)[result valueForKey:kKeychainItemKey];
    if (item) {
      // put it on the clipboard
      NSString *password = [item password];
      [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:self];
      [[NSPasteboard generalPasteboard] setString:password forType:NSStringPboardType];

      // don't keep the data around
      [item unloadData];
    }
  }
  return YES;
}
@end

@interface CopyAccountNameAction : HGSAction
@end

@implementation CopyAccountNameAction
- (BOOL)performWithInfo:(NSDictionary*)info {
  HGSResultArray *directObjects = [info objectForKey:kHGSActionDirectObjectsKey];
  for (HGSResult *result in directObjects) {
    HGSLogDebug(@"copy account name action invoked on '%@'", [result displayName]);
    
    KeychainItem* item = (KeychainItem*)[result valueForKey:kKeychainItemKey];
    if (item) {
      // put it on the clipboard
      NSString *accountName = [item username];
      [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:self];
      [[NSPasteboard generalPasteboard] setString:accountName forType:NSStringPboardType];

      // don't keep the data around
      [item unloadData];
    }
  }
  return YES;
}
@end

@interface ShowKeychainItemAction : HGSAction
@end

@implementation ShowKeychainItemAction
- (BOOL)performWithInfo:(NSDictionary*)info {
  HGSResultArray *directObjects = [info objectForKey:kHGSActionDirectObjectsKey];
  for (HGSResult *result in directObjects) {
    HGSLogDebug(@"show keychain item invoked on '%@'", [result displayName]);
    
    KeychainItem* item = (KeychainItem*)[result valueForKey:kKeychainItemKey];
    if (item) {
      // display in a message
      NSString *message = [NSString stringWithFormat:@"Account Name: %@\nPassword: %@", [item username], [item password]];
      NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
      NSDictionary *messageDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [result displayName], kHGSSummaryMessageKey,
                                   message, kHGSDescriptionMessageKey,
                                   kHGSSuccessCodeSuccess, kHGSSuccessCodeMessageKey,
                                   nil];
      [nc postNotificationName:kHGSUserMessageNotification 
                        object:self
                      userInfo:messageDict];

      // don't keep the data around
      [item unloadData];
    }
  }
  return YES;
}
@end
