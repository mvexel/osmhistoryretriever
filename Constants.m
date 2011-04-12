//
//  Constants.m
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 19-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import "Constants.h"

NSString * const kOSMXMLHeader =  @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><osm version=\"0.6\" generator=\"OSMHistoryRetriever\">";
NSString * const kOSMXMLFooter =  @"</osm>";
NSString * const kHistoryRetrievedForGeometryNotificationName = @"HistoryRetrievedForGeometry";
NSString * const kHistoryRetrieveFailedForGeometryNotificationName = @"HistoryRetrieveFailedForGeometry";
NSString * const kUpdatePercentDoneNotificationName = @"UpdatePercentDone";
NSString * const kDoneNotificationName = @"Done";

extern int const kMaxTries = 5;

@implementation Constants

@end
