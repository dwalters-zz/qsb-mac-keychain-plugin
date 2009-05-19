//
//  KeychainItemsAction.m
//  KeychainItems
//
//  Created by Dan Walters on 5/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <Vermilion/Vermilion.h>
#import <Security/Security.h>

extern NSString *kKeychainAttrItemRef;

@interface KeychainItemsAction : HGSAction
@end

@implementation KeychainItemsAction

// Perform an action given a dictionary of info. For now, we are just passing
// in an array of direct objects, but there may be more keys added to future
// SDKs
- (BOOL)performWithInfo:(NSDictionary*)info {
  HGSResultArray *directObjects = [info objectForKey:kHGSActionDirectObjectsKey];
  for (HGSResult *result in directObjects) {
    HGSLogDebug(@"keychain action invoked on '%@'", [result displayName]);
    SecKeychainItemRef itemRef = (SecKeychainItemRef)[result valueForKey:kKeychainAttrItemRef];
    if (itemRef) {
      HGSLogDebug(@"copying password to clipboard");

      // fetch the data
      UInt32 len;
      char *data;
      OSStatus res = SecKeychainItemCopyContent(itemRef, NULL, NULL, &len, (void**)&data);
      if (res != noErr) {
        HGSLog(@"KeychainItemsAction: error %d while copying keychain item data", res);
        return NO;
      }
      NSString *content = [NSString stringWithCString:data length:len];

#if 1
      NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
      NSDictionary *messageDict = [NSDictionary dictionaryWithObjectsAndKeys:
        [result displayName], kHGSSummaryMessageKey,
        content, kHGSDescriptionMessageKey,
        kHGSSuccessCodeSuccess, kHGSSuccessCodeMessageKey,
        nil];
      [nc postNotificationName:kHGSUserMessageNotification 
                        object:self
                      userInfo:messageDict];
#else
      // put it on the clipboard
      [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:self];
      [[NSPasteboard generalPasteboard] setString:content forType:NSStringPboardType];
#endif

      // free the free
      SecKeychainItemFreeContent(NULL, data);
    }
  }
  return YES;
}
@end
