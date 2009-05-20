//
//  KeychainItemExt.m
//  KeychainItems
//
//  Created by Dan Walters on 5/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KeychainItemExt.h"

@implementation KeychainItem (KeychainItemsExt)
- (void)unloadData {
  [mUsername autorelease];
  mUsername = nil;
  [mPassword autorelease];
  mPassword = nil;
  mDataLoaded = NO;
}
@end
