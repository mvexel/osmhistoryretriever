//
//  Constants.h
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 19-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kOSMXMLHeader;
extern NSString * const kOSMXMLFooter;
extern NSString * const kHistoryRetrievedForGeometryNotificationName;
extern NSString * const kHistoryRetrieveFailedForGeometryNotificationName;
extern NSString * const kUpdatePercentDoneNotificationName;
extern NSString * const kDoneNotificationName;

extern int const kMaxTries;

@interface Constants : NSObject {

}

@end
