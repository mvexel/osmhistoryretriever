//
//  OSMNode.h
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 13-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSMGeometry.h"
#import "Coordinate.h"

@interface OSMNode : OSMGeometry {
	Coordinate *coordinate;
}

@property (nonatomic,retain) Coordinate * coordinate;

@end
