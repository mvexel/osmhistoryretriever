//
//  OSMGeometry.h
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 13-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ISO8601DateFormatter.h"

@class OSMMap;

@interface OSMGeometry : NSObject <NSXMLParserDelegate> {
	int osmID;
	int osmVersion;
	int changeset;
	int userID;
	NSString * userName;
	BOOL visible;
	BOOL currentVersion;
	NSDictionary * tags;
	NSDate * osmTimestamp;
	NSMutableData *receivedData;
	NSXMLParser *parser;
	id currentElement;
	NSMutableArray *keys;
	NSMutableArray *values;
	NSMutableArray *noderefs;
	ISO8601DateFormatter *dateFormatter;
	BOOL parsingTags;
	BOOL gotFullHistory;
	NSMutableArray *history;
	NSMutableArray *relationMembers;
	OSMMap * theMap;
	int trycount;
}

@property (nonatomic) int osmID;
@property (nonatomic) int osmVersion;
@property (nonatomic) int changeset;
@property (nonatomic) int userID;
@property (nonatomic,copy) NSString * userName;
@property (nonatomic) BOOL visible;
@property (nonatomic) BOOL currentVersion;
@property (nonatomic) BOOL gotFullHistory;
@property (nonatomic,retain) NSDictionary * tags;
@property (nonatomic,retain) NSDate * osmTimestamp;
@property (nonatomic,retain) NSMutableArray *noderefs;
@property (nonatomic,retain) NSMutableArray * relationMembers;

-(void)retrieveHistory;
-(NSString *)xmlRepresentationForVersion:(int)version;
-(NSString *)xmlRepresentationWithFullHistory;

@end
