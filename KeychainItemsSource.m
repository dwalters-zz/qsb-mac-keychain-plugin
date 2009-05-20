//
//  KeychainItemsSource.m
//  KeychainItems
//
//  Created by Dan Walters on 5/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <Vermilion/Vermilion.h>
#import "KeychainItemExt.h"

const NSString *kKeychainItemKey = @"keychainItem";
static NSString *kKeychainItemType = @"keychain";
static NSString *kCopyPasswordAction = @"com.github.dwalters.qsb.keychain.copypassword";

@interface KeychainItemsSource : HGSMemorySearchSource {
 @private
  NSImage *keychainIcon_;
}
- (void)updateIndex;
@end

// callback for when the keychain has been updated
static OSStatus KeychainModified(SecKeychainEvent keychainEvent,
                                 SecKeychainCallbackInfo *info,
                                 void *context)
{
	HGSLogDebug(@"keychain modification event received");
	KeychainItemsSource *source = (KeychainItemsSource *)context;
	[source updateIndex];
	return noErr;
}

@implementation KeychainItemsSource

- (HGSResult*)resultForItem:(SecKeychainItemRef)itemRef ofClass:(SecItemClass)itemClass {
  CFRetain(itemRef); // KeychainItem releases but doesn't retain
  KeychainItem *item = [[[KeychainItem alloc] initWithRef:itemRef] autorelease];

	// create and return the result
  NSString *name = [item label];
  NSString *urlString = [NSString stringWithFormat:@"keychain://%@/%@",
                         @"default",
                         [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSMutableDictionary *attributes =
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
      keychainIcon_, kHGSObjectAttributeIconKey,
      item, kKeychainItemKey,
      nil];
  HGSAction *action = [[HGSExtensionPoint actionsPoint] extensionWithIdentifier:kCopyPasswordAction];
  if (action) {
    [attributes setObject:action forKey:kHGSObjectAttributeDefaultActionKey];
  }
	return [HGSResult resultWithURL:[NSURL URLWithString:urlString]
                             name:name
                             type:kKeychainItemType
                           source:self
                       attributes:attributes];
}

- (id)initWithConfiguration:(NSDictionary *)configuration {
	if ((self = [super initWithConfiguration:configuration])) {
    // use the keychain access icon
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    keychainIcon_ = [ws iconForFile:[ws absolutePathForAppBundleWithIdentifier:@"com.apple.keychainaccess"]];
    [keychainIcon_ retain];

		// build the initial index
		[self updateIndex];
    
		// register a callback for when the keychain is modified
		OSStatus result = SecKeychainAddCallback(KeychainModified,
                                             kSecAddEventMask
                                             | kSecDeleteEventMask 
                                             | kSecUpdateEventMask 
                                             | kSecDefaultChangedEventMask 
                                             | kSecKeychainListChangedMask,
                                             self);
		if (result != noErr) {
			HGSLog(@"KeychainItemsSource: error %d while adding modification callback", result);
		}
	}
	return self;
}

- (void)dealloc {
	// remove the keychain modification callback
	OSStatus result = SecKeychainRemoveCallback(KeychainModified);
	if (result != noErr) {
		HGSLog(@"KeychainItemsSource: error %d while removing modification callback", result);
	}

  [keychainIcon_ release];
	[super dealloc];
}

- (void)searchSecurityClass:(SecItemClass)targetClass {
	SecKeychainSearchRef searchRef;
	OSStatus result = SecKeychainSearchCreateFromAttributes(NULL, targetClass, NULL, &searchRef);
	if (result != noErr) {
		HGSLog(@"KeychainItemsSource: error %d while starting search", result);
		return;
	}
	
	SecKeychainItemRef itemRef;
	while ((result = SecKeychainSearchCopyNext(searchRef, &itemRef)) == noErr) {
		
		// create an indexable result for the item and index it
		HGSResult* newResult = [self resultForItem:itemRef ofClass:targetClass];
		if (newResult) {
			[self indexResult:newResult];
		}

		CFRelease(itemRef);
	}
	if (result != errSecItemNotFound) {
		HGSLog(@"KeychainItemsSource: error %d while iterating through search results", result);
	}
	
	CFRelease(searchRef);
}

- (void)updateIndex {
	HGSLogDebug(@"updating index");
	[self clearResultIndex];
	[self searchSecurityClass:kSecInternetPasswordItemClass];
	[self searchSecurityClass:kSecGenericPasswordItemClass];
}

@end
