//
//  KeychainItemExt.h
//  KeychainItems
//
//  Created by Dan Walters on 5/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Vermilion/KeychainItem.h>

@interface KeychainItem()
- (KeychainItem*)initWithRef:(SecKeychainItemRef)ref;
@end

@interface KeychainItem (KeychainItemsExt)
- (NSString*)label;
- (void)unloadData;
@end
