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

@interface KeychainItemsAction : HGSAction
@end

@implementation KeychainItemsAction

- (BOOL)performWithInfo:(NSDictionary*)info {
  HGSResultArray *directObjects = [info objectForKey:kHGSActionDirectObjectsKey];
  for (HGSResult *result in directObjects) {
    HGSLogDebug(@"keychain action invoked on '%@'", [result displayName]);

    KeychainItem* item = (KeychainItem*)[result valueForKey:kKeychainItemKey];
    if (item) {
#if 1
      // display in a message
      NSString *message = [NSString stringWithFormat:@"Username: %@\nPassword: %@", [item username], [item password]];
      NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
      NSDictionary *messageDict = [NSDictionary dictionaryWithObjectsAndKeys:
        [result displayName], kHGSSummaryMessageKey,
        message, kHGSDescriptionMessageKey,
        kHGSSuccessCodeSuccess, kHGSSuccessCodeMessageKey,
        nil];
      [nc postNotificationName:kHGSUserMessageNotification 
                        object:self
                      userInfo:messageDict];
#endif

#if 1
      // put it on the clipboard
      NSString *password = [item password];
      [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:self];
      [[NSPasteboard generalPasteboard] setString:password forType:NSStringPboardType];
#endif

      // don't keep the data around
      [item unloadData];
    }
  }
  return YES;
}
@end
