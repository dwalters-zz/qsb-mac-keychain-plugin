//
//  KeychainItemExt.m
//  KeychainItems
//
//  Created by Dan Walters on 5/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KeychainItemExt.h"

@implementation KeychainItem (KeychainItemsExt)
- (NSString*)label {
  // desired attributes
  SecKeychainAttribute labelAttr;
  labelAttr.tag = kSecLabelItemAttr;
  SecKeychainAttributeList attrList = {1, &labelAttr};

  // retrieve the attributes
  OSStatus result = SecKeychainItemCopyContent(mKeychainItemRef, NULL, &attrList, NULL, NULL);
  if (result != noErr) {
    HGSLog(@"KeychainItemsSource: error %d while getting item content", result);
    return nil;
  }

  return [NSString stringWithCString:labelAttr.data
                              length:labelAttr.length];
}

- (void)unloadData {
  // TODO: really, the only sensistive data is the contents (i.e., mPassword) and the
  //       rest could be cached, but I don't want to mess too much with the existing code
  //       just yet.
  [mUsername autorelease];
  mUsername = nil;
  [mPassword autorelease];
  mPassword = nil;
  mDataLoaded = NO;
}
@end
