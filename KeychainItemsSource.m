//
//  KeychainItemsSource.m
//  KeychainItems
//
//  Created by Dan Walters on 5/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <Vermilion/Vermilion.h>
#import <Security/Security.h>

@interface KeychainItemsSource : HGSMemorySearchSource
- (void)updateIndex;
@end

// callback for when the keychain has been updated
static OSStatus KeychainModified(SecKeychainEvent keychainEvent,
								 SecKeychainCallbackInfo *info,
								 void *context)
{
	KeychainItemsSource *source = (KeychainItemsSource *)context;
	[source updateIndex];
	return noErr;
}

@implementation KeychainItemsSource

- (id)initWithConfiguration:(NSDictionary *)configuration {
	if ((self = [super initWithConfiguration:configuration])) {
		// build the initial index
		[self updateIndex];

		// register a callback for when the keychain is modified
		if (SecKeychainAddCallback(KeychainModified, kSecAddEventMask | kSecDeleteEventMask | kSecUpdateEventMask | kSecDefaultChangedEventMask | kSecKeychainListChangedMask, self)) {
			NSLog(@"error adding keychain callback");
		}
	}
	return self;
}

- (void)dealloc {
	// remove the keychain modification callback
	if (SecKeychainRemoveCallback(KeychainModified)) {
		NSLog(@"error removing keychain callback");
	}

	[super dealloc];
}

- (void)updateIndex {
	[self clearResultIndex];

	// TODO: want more than internet password items
	SecKeychainSearchRef searchRef = NULL;
	if (SecKeychainSearchCreateFromAttributes(NULL, kSecInternetPasswordItemClass, NULL, &searchRef)) {
		NSLog(@"error creating keychain search");
		return;
	}

	SecKeychainItemRef itemRef;
	while (!SecKeychainSearchCopyNext(searchRef, &itemRef)) {
		NSDictionary* dictionary = [NSDictionary dictionary];
		// TODO: get the item name from the itemRef and store in the dictionary

		// add the item to the search index
		HGSResult* result = [HGSResult resultWithDictionary:dictionary source:self];
		[self indexResult:result];

		CFRelease(itemRef);
	}

	CFRelease(searchRef);
}

@end
