//
//  OSMMap.h
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 13-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSMNode.h"
#import "OSMWay.h"
#import "OSMRelation.h"
#import "ISO8601DateFormatter.h"
#import "BoundingBox.h"

@interface OSMMap : NSObject <NSXMLParserDelegate> {
	NSMutableArray * nodes;
	NSMutableArray * ways;
	NSMutableArray * relations;
	BoundingBox *boundingBox;
	id currentElement;
	ISO8601DateFormatter * dateFormatter;
	BOOL parsingTags;
	NSMutableArray * keys;
	NSMutableArray * values;
	NSMutableArray * noderefs;
	NSMutableArray * relationMembers;
	NSMutableData * receivedData;
	NSMutableArray * xmlRepresentationWithFullHistory;
	NSMutableData *fullHistoryOutData;
	NSURL *osmFileURL;
	int numberOfGeometriesThatWeHaveHistoryFor;
	int totalNumberOfGeometries;
	float percentComplete;
	BOOL gotFullHistory;
}

@property (nonatomic,retain) NSMutableArray *nodes;
@property (nonatomic,retain) NSMutableArray *ways;
@property (nonatomic,retain) NSMutableArray *relations;
@property (nonatomic,retain) BoundingBox * boundingBox;
@property (nonatomic,retain) NSMutableArray *xmlRepresentationWithFullHistory;
@property (nonatomic,retain) NSURL *osmFileURL;
@property (nonatomic,retain) NSMutableData *fullHistoryOutData;
@property (nonatomic) BOOL gotFullHistory;
@property (nonatomic) int numberOfGeometriesThatWeHaveHistoryFor;
@property (nonatomic) int totalNumberOfGeometries;
@property (nonatomic,readonly) float percentComplete;

+(OSMMap *)sharedInstance;

@end
