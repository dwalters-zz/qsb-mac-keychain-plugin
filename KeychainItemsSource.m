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

+ (HGSResult*)resultForItem:(SecKeychainItemRef)itemRef ofClass:(SecItemClass)itemClass {
	// desired attributes
	SecKeychainAttribute labelAttr;
	labelAttr.tag = kSecLabelItemAttr;
	SecKeychainAttributeList attrList = {1, &labelAttr};

	// retrieve the attributes
	OSStatus status = SecKeychainItemCopyContent(itemRef, NULL, &attrList, NULL, NULL);
	if (status != noErr) {
		NSLog(@"KeychainItemsSource: error %d while getting item content", status);
		return nil;
	}

	// create and return the result
	NSString *label = [NSString stringWithCString:labelAttr.data
										   length:labelAttr.length];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"keychain://%@/%@", @"default", label]];
	NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:(int)itemRef] forKey:@"SecItemRef"];
	HGSResult* result = [HGSResult resultWithURL:url
											name:label
											type:@"KeychainItem"
										  source:self
									  attributes:attributes];
//	NSLog(@"KeychainItemsSource: adding %@ to cache", label);
	return result;
}

- (id)initWithConfiguration:(NSDictionary *)configuration {
	if ((self = [super initWithConfiguration:configuration])) {
		// build the initial index
		[self updateIndex];

		// register a callback for when the keychain is modified
		OSStatus status = SecKeychainAddCallback(KeychainModified, kSecAddEventMask | kSecDeleteEventMask | kSecUpdateEventMask | kSecDefaultChangedEventMask | kSecKeychainListChangedMask, self);
		if (status != noErr) {
			NSLog(@"KeychainItemsSource: error %d while adding modification callback", status);
			// can consider failure OK here
		}
	}
	return self;
}

- (void)dealloc {
	// remove the keychain modification callback
	OSStatus status = SecKeychainRemoveCallback(KeychainModified);
	if (status != noErr) {
		NSLog(@"KeychainItemsSource: error %d while removing modification callback", status);
	}

	[super dealloc];
}

- (void)searchSecurityClass:(SecItemClass)targetClass {
	SecKeychainSearchRef searchRef;
	OSStatus status = SecKeychainSearchCreateFromAttributes(NULL, targetClass, NULL, &searchRef);
	if (status != noErr) {
		NSLog(@"KeychainItemsSource: error %d while starting search", status);
		return;
	}
	
	SecKeychainItemRef itemRef;
	while ((status = SecKeychainSearchCopyNext(searchRef, &itemRef)) == noErr) {
		
		// create an indexable result for the item and index it
		HGSResult* result = [[self class] resultForItem:itemRef ofClass:targetClass];
		if (result) {
			[self indexResult:result];
		}

		CFRelease(itemRef);
	}
	if (status != errSecItemNotFound) {
		NSLog(@"KeychainItemsSource: error %d while iterating through search results", status);
	}
	
	CFRelease(searchRef);
}

- (void)updateIndex {
	[self clearResultIndex];
	[self searchSecurityClass:kSecInternetPasswordItemClass];
	[self searchSecurityClass:kSecGenericPasswordItemClass];
}

@end
