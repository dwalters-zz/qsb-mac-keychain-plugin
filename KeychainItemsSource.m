//
//  KeychainItemsSource.m
//  KeychainItems
//
//  Created by Dan Walters on 5/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <Vermilion/Vermilion.h>
#import <Security/Security.h>

NSString *kKeychainAttrItemRef = @"keychainItemRef";
static NSString *kKeychainItemType = @"keychain";

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
	HGSLogDebug(@"KeychainItemsSource: modification event received");
	KeychainItemsSource *source = (KeychainItemsSource *)context;
	[source updateIndex];
	return noErr;
}

@implementation KeychainItemsSource

- (HGSResult*)resultForItem:(SecKeychainItemRef)itemRef ofClass:(SecItemClass)itemClass {
	// desired attributes
	SecKeychainAttribute labelAttr;
	labelAttr.tag = kSecLabelItemAttr;
	SecKeychainAttributeList attrList = {1, &labelAttr};
  
	// retrieve the attributes
	OSStatus result = SecKeychainItemCopyContent(itemRef, NULL, &attrList, NULL, NULL);
	if (result != noErr) {
		HGSLog(@"KeychainItemsSource: error %d while getting item content", result);
		return nil;
	}
  
	// create and return the result
	NSString *label = [NSString stringWithCString:labelAttr.data
                                         length:labelAttr.length];
	NSString *url = [NSString stringWithFormat:@"keychain://%@/%@", @"default", label];
	NSMutableDictionary *attributes =
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
      keychainIcon_, kHGSObjectAttributeIconKey,
      itemRef, kKeychainAttrItemRef,
      nil];
	return [HGSResult resultWithURL:[NSURL URLWithString:url]
                             name:label
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
			HGSLogDebug(@"KeychainItemsSource: adding '%@' to cache", [newResult displayName]);
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
	HGSLogDebug(@"KeychainItemsSource: updateIndex");
	[self clearResultIndex];
	[self searchSecurityClass:kSecInternetPasswordItemClass];
	[self searchSecurityClass:kSecGenericPasswordItemClass];
}

@end
