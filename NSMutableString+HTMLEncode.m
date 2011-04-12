//
//  NSMutableString+HTMLEncode.m
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 28-02-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSMutableString+HTMLEncode.h"


@implementation NSMutableString (HTMLEncode)

- (NSMutableString *)HTMLEncode {
	return [[[[[[self stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;"] stringByReplacingOccurrencesOfString: @"\"" withString: @"&quot;"] stringByReplacingOccurrencesOfString: @"'" withString: @"&#39;"] stringByReplacingOccurrencesOfString: @">" withString: @"&gt;"] stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"] mutableCopy];
}
@end
