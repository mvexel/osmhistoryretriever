//
//  OSMMap.m
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 13-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import "OSMMap.h"
#import "Constants.h"

static OSMMap * sharedInstance = nil;

@implementation OSMMap

@synthesize nodes,ways,relations,boundingBox,xmlRepresentationWithFullHistory,osmFileURL,fullHistoryOutData,gotFullHistory,numberOfGeometriesThatWeHaveHistoryFor,totalNumberOfGeometries;

-(float)percentComplete {
	return (float)(100 * numberOfGeometriesThatWeHaveHistoryFor) / (float)([nodes count] + [ways count] + [relations count]);
}

-(int)totalNumberOfGeometries {
	return [nodes count] + [ways count] + [relations count];
}

-(BOOL)gotFullHistory {
	BOOL gotIt = ([nodes count] + [ways count] + [relations count]) == numberOfGeometriesThatWeHaveHistoryFor;
	NSLog(@"full history? %u",gotIt);
	return gotIt;
}

-(void)historyStatus:(NSNotification *)n {
	if ([[n name] isEqualToString:kHistoryRetrieveFailedForGeometryNotificationName]) {
		NSLog(@"we gave up!");
		NSLog(@"count before: n:%u w:%u r:%u",[nodes count],[ways count],[relations count]);
		if ([[n object] isKindOfClass:[OSMNode class]]) {
			[nodes removeObjectIdenticalTo:[n object]];
		}
			 if ([[n object] isKindOfClass:[OSMWay class]]) {
			[ways removeObjectIdenticalTo:[n object]];
		}
				  if ([[n object] isKindOfClass:[OSMRelation class]]) {
			[relations removeObjectIdenticalTo:[n object]];
		}
		NSLog(@"count before: n:%u w:%u r:%u",[nodes count],[ways count],[relations count]);
		numberOfGeometriesThatWeHaveHistoryFor--;					   
	}
	NSLog(@"name of not: %@",[n name]);
	numberOfGeometriesThatWeHaveHistoryFor++;
	NSLog(@"percent done: %@ - %f",[NSString stringWithFormat:@"%f",[self percentComplete]],[self percentComplete]);
	[[NSNotificationCenter defaultCenter] postNotificationName:kUpdatePercentDoneNotificationName object:[NSString stringWithFormat:@"%f",[self percentComplete]]];
	if ([self gotFullHistory]) {
		NSLog(@"writing file: %@",[osmFileURL description]);
		NSLog(@"length: %u",[fullHistoryOutData length]);
		[fullHistoryOutData appendData:[kOSMXMLFooter dataUsingEncoding:NSUTF8StringEncoding]];
		[fullHistoryOutData writeToURL:osmFileURL atomically:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:kDoneNotificationName object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:kHistoryRetrievedForGeometryNotificationName object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:kHistoryRetrieveFailedForGeometryNotificationName object:nil];
	}
}

-(void)setBoundingBox:(BoundingBox *)newBoundingBox {
	numberOfGeometriesThatWeHaveHistoryFor = 0;
	fullHistoryOutData = [[NSMutableData alloc] initWithData:[kOSMXMLHeader dataUsingEncoding:NSUTF8StringEncoding]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyStatus:) name:kHistoryRetrievedForGeometryNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyStatus:) name:kHistoryRetrieveFailedForGeometryNotificationName object:nil];
	[boundingBox release];
	boundingBox = [newBoundingBox retain];
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.openstreetmap.org/api/0.6/map?bbox=%.5f,%.5f,%.5f,%.5f",boundingBox.leftBottom.lon,boundingBox.leftBottom.lat,boundingBox.rightTop.lon,boundingBox.rightTop.lat]]];
	NSURLConnection *conn = [NSURLConnection connectionWithRequest:req delegate:self];
	if (conn) {
		receivedData = [[NSMutableData alloc] init];
	} else {
		// TODO: implement
	}
	
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"startedDocument" object:nil]];
	nodes = [[NSMutableArray alloc] init];
	ways = [[NSMutableArray alloc] init];
	relations = [[NSMutableArray alloc] init];
	dateFormatter = [[ISO8601DateFormatter alloc] init];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"node"]) {
		currentElement = [[OSMNode alloc] init];		
		[currentElement setCoordinate:[Coordinate coordinateWithLongitude:[[attributeDict valueForKey:@"lon"] doubleValue] andLatitude:[[attributeDict valueForKey:@"lat"] doubleValue]]];
	}
	if ([elementName isEqualToString:@"way"]) {
		currentElement = [[OSMWay alloc] init];
		noderefs = [[NSMutableArray alloc] init];
	}
	if ([elementName isEqualToString:@"relation"]) {
		currentElement = [[OSMRelation alloc] init];		
		relationMembers = [[NSMutableArray alloc] init];
	}
	if ([elementName isEqualToString:@"node"] || [elementName isEqualToString:@"way"] || [elementName isEqualToString:@"relation"]) {
		// TODO: is this currentVersion var really necessary?
		[currentElement setCurrentVersion:YES];
		[currentElement setOsmID:[[attributeDict valueForKey:@"id"] intValue]];
		[currentElement setOsmVersion:[[attributeDict valueForKey:@"version"] intValue]];
		[currentElement setChangeset:[[attributeDict valueForKey:@"changeset"] intValue]];
		[currentElement setUserID:[[attributeDict valueForKey:@"uid"] intValue]];
		[currentElement setUserName:[attributeDict valueForKey:@"user"]];
		[currentElement setOsmTimestamp:[dateFormatter dateFromString:[attributeDict valueForKey:@"timestamp"]]]; 
		 if(!parsingTags) {
			keys = [[NSMutableArray alloc] init];
			values = [[NSMutableArray alloc] init];
			parsingTags = YES;
		}
	}
	if ([elementName isEqualToString:@"tag"]) {
		[keys addObject:[attributeDict valueForKey:@"k"]];
		[values addObject:[attributeDict valueForKey:@"v"]];
//		NSLog(@"keys is now %@ values is now %@",[keys description],[values description]);
	}
	if ([elementName isEqualToString:@"nd"])
		[noderefs addObject:[attributeDict valueForKey:@"ref"]];
	if ([elementName isEqualToString:@"member"])
		[relationMembers addObject:attributeDict];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"node"] || [elementName isEqualToString:@"way"] || [elementName isEqualToString:@"relation"]) {
		if([keys count] > 0 && [values count] > 0)
			[currentElement setTags: [[NSDictionary alloc] initWithObjects:values forKeys:keys]];
		parsingTags = NO;
	}
	if ([elementName isEqualToString:@"node"])
		[nodes addObject:currentElement];
	if ([elementName isEqualToString:@"way"])
		[ways addObject:currentElement];
	if ([elementName isEqualToString:@"relation"])
		[relations addObject:currentElement];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"finished" object:nil]];
	NSLog(@"finished parsing. %u nodes, %u ways, %u relations",[nodes count], [ways count], [relations count]);
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"parseError" object:parseError]];
}

#pragma mark -
#pragma mark Singleton methods

+ (OSMMap *)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
			sharedInstance = [[OSMMap alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"loadingFailed" object:error]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"finishedLoading" object:nil]];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:receivedData];
	[parser setDelegate:self];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	
}


@end
