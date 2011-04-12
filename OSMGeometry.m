//
//  OSMGeometry.m
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 13-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import "OSMGeometry.h"
#import "Coordinate.h"
#import "OSMNode.h"
#import "OSMWay.h"
#import "OSMRelation.h"
#import "Constants.h"

@implementation OSMGeometry

@synthesize osmID;
@synthesize osmVersion;
@synthesize changeset;
@synthesize userID;
@synthesize userName;
@synthesize visible;
@synthesize currentVersion;
@synthesize tags;
@synthesize osmTimestamp;
@synthesize gotFullHistory;
@synthesize noderefs;
@synthesize relationMembers;

-(void)setOsmID:(int)newOsmID {
	trycount = 0;
	osmID = newOsmID;
//	NSLog(@"osm id set for %u",osmID);
	if(currentVersion)
		[self retrieveHistory];
}

-(void)retrieveHistory {
	NSLog(@"going to retrieve history for OSM ID %u, try %u",osmID,trycount);
	if (trycount >= kMaxTries) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kHistoryRetrieveFailedForGeometryNotificationName object:self];
	} else {
		NSString *featureTypeIdentifier;
		if ([self isKindOfClass:[OSMNode class]]) {
			featureTypeIdentifier = @"node";
		} else if ([self isKindOfClass:[OSMWay class]]) {
			featureTypeIdentifier = @"way";
		} else if ([self isKindOfClass:[OSMRelation class]]) {
			featureTypeIdentifier = @"relation";
		}
		NSString * urlString = [NSString stringWithFormat:@"http://www.openstreetmap.org/api/0.6/%@/%u/history/",featureTypeIdentifier,osmID];
		NSLog(@"url to retrieve: %@",urlString);
		NSURL *historyURL = [NSURL URLWithString:urlString];
		NSURLRequest * historyRequest = [NSURLRequest requestWithURL:historyURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:(trycount * 30)];
		NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:historyRequest delegate:self];
		if (conn) {
			receivedData = [[NSMutableData alloc] init];	
		} else {
			NSLog(@"connection failed for %u - trying again in a sec",osmID);
			if (trycount < kMaxTries) {
				trycount++;
				[self performSelector:@selector(retrieveHistory) withObject:nil afterDelay:1.0];
			}
		}
	}
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
	NSLog(@"history could not be retrieved for %u - trying again in a sec",osmID);
	if (trycount < kMaxTries) {
		trycount++;
		[self performSelector:@selector(retrieveHistory) withObject:nil afterDelay:1.0];
	}
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:kHistoryRetrieveFailedForGeometryNotificationName object:self];
	}

	//[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"loadingFailed" object:error]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	//[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"finishedLoading" object:nil]];
//	NSLog(@"history gotten, %u bytes",[receivedData length]);
	parser = [[NSXMLParser alloc] initWithData:receivedData];
	[parser setDelegate:self];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser {
//	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"startedDocument" object:nil]];
	history = [[NSMutableArray alloc] init];
	dateFormatter = [[ISO8601DateFormatter alloc] init];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"node"]) {
		currentElement = [[OSMNode alloc] init];
		[currentElement setCurrentVersion:NO];
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
		// TODO: implement nodes, ways, relations as singletons.
		// so we can access the node store from any object easily.
		// or should each osm feature hold its own history array? like it is done now?
		[history addObject:currentElement];
	if ([elementName isEqualToString:@"way"])
		[history addObject:currentElement];
	if ([elementName isEqualToString:@"relation"])
		[history addObject:currentElement];
	if ([elementName isEqualToString:@"osm"]) {
		[self setGotFullHistory:YES];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"finished" object:nil]];
	NSLog(@"finished parsing history for %u. %u versions",osmID, [history count]);
	if ([receivedData length] == 0 || !receivedData) {
		NSLog(@"Document was empty, that's not OK");
		trycount++;
		[self performSelector:@selector(retrieveHistory) withObject:nil afterDelay:1.0];
	}
	else {
		//	NSLog(@"xml: %@",[self xmlRepresentationWithFullHistory]);
		theMap = [OSMMap sharedInstance];
		[[theMap fullHistoryOutData] appendData:[[self xmlRepresentationWithFullHistory] dataUsingEncoding:NSUTF8StringEncoding]];
		[[NSNotificationCenter defaultCenter] postNotificationName:kHistoryRetrievedForGeometryNotificationName object:self];
	}
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"parse error for %u. error: %@ - trying again in one sec",osmID, [parseError description]);
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"parseError" object:parseError]];
	trycount++;
	[self performSelector:@selector(retrieveHistory) withObject:nil afterDelay:1.0];
}

-(NSString *)xmlRepresentationForVersion:(int)version {
	return nil;
}

-(NSString *)xmlRepresentationWithFullHistory {
return nil;
}

@end
