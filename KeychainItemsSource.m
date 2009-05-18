//
//  KeychainItemsSource.m
//  KeychainItems
//
//  Created by Dan Walters on 5/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <Vermilion/Vermilion.h>

@interface KeychainItemsSource : HGSCallbackSearchSource
@end

@implementation KeychainItemsSource

//- (BOOL)isValidSourceForQuery:(HGSQuery *)query {
//  return YES;
//}

// Collect results for a search operation. You can use the pivot object
// and unique words to perform your search
- (void)performSearchOperation:(HGSSearchOperation*)operation {
  // The query
  // HGSQuery *query = [operation query];
  // The pivot object (if any)
  // HGSResult *pivotObject = [query pivotObject];
  // NSArray *words = [query uniqueWords];
  NSURL *url = [NSURL URLWithString:@"http://localhost"];
  HGSResult *result = [HGSResult resultWithURL:url
                                          name:NSStringFromClass([self class])
                                          type:kHGSTypeWebpage
                                        source:self
                                    attributes:nil];
  [operation setResults:[NSArray arrayWithObject:result]];
}

@end
