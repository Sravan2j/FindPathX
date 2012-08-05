//
//  DemoView.m
//  FindPathX
//
//  Created by Matt on 9/5/08.
//  

#import "DemoView.h"



/****************** PathFindNode <--- Object that holds node information (cost, x, y, etc.) */
@interface PathFindNode : NSObject {
@public
	int nodeX,nodeY;
	int cost;
	PathFindNode *parentNode;
}
+(id)node;
@end
@implementation PathFindNode
+(id)node
{
	return [[[PathFindNode alloc] init] autorelease];
}
@end
/*********************************************************************************/



@implementation DemoView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// A* methods begin//////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)spaceIsBlocked:(int)x :(int)y;
{
	//general-purpose method to return whether a space is blocked
	if(tileMap[x][y] == TILE_WALL)
		return YES;
	else
		return NO;
}

-(PathFindNode*)nodeInArray:(NSMutableArray*)a withX:(int)x Y:(int)y
{
	//Quickie method to find a given node in the array with a specific x,y value
	NSEnumerator *e = [a objectEnumerator];
	PathFindNode *n;
	
	while((n = [e nextObject]))
	{
		if((n->nodeX == x) && (n->nodeY == y))
		{
			return n;
		}
	}
	
	return nil;
}
-(PathFindNode*)lowestCostNodeInArray:(NSMutableArray*)a
{
	//Finds the node in a given array which has the lowest cost
	PathFindNode *n, *lowest;
	lowest = nil;
	NSEnumerator *e = [a objectEnumerator];
	
	while((n = [e nextObject]))
	{
		if(lowest == nil)
		{
			lowest = n;
		}
		else
		{
			if(n->cost < lowest->cost)
			{
				lowest = n;
			}
		}
	}
	return lowest;
}

-(void)findPath:(int)startX :(int)startY :(int)endX :(int)endY
{
	//find path function. takes a starting point and end point and performs the A-Star algorithm
	//to find a path, if possible. Once a path is found it can be traced by following the last
	//node's parent nodes back to the start
	
	int x,y;
	int newX,newY;
	int currentX,currentY;
	NSMutableArray *openList, *closedList;
	
	if((startX == endX) && (startY == endY))
		return; //make sure we're not already there
	
	openList = [NSMutableArray array]; //array to hold open nodes
	
	BOOL animate = [shouldAnimateButton state];
	if(animate)
		pointerToOpenList = openList;
	
	closedList = [NSMutableArray array]; //array to hold closed nodes
	
	PathFindNode *currentNode = nil;
	PathFindNode *aNode = nil;
	
	//create our initial 'starting node', where we begin our search
	PathFindNode *startNode = [PathFindNode node];
	startNode->nodeX = startX;
	startNode->nodeY = startY;
	startNode->parentNode = nil;
	startNode->cost = 0;
	//add it to the open list to be examined
	[openList addObject: startNode];
	
	while([openList count])
	{
		//while there are nodes to be examined...
		
		//get the lowest cost node so far:
		currentNode = [self lowestCostNodeInArray: openList];
		
		if((currentNode->nodeX == endX) && (currentNode->nodeY == endY))
		{
			//if the lowest cost node is the end node, we've found a path
			
			//********** PATH FOUND ********************	
			
			//*****************************************//
			//NOTE: Code below is for the Demo app to trace/mark the path
			aNode = currentNode->parentNode;
			while(aNode->parentNode != nil)
			{
				tileMap[aNode->nodeX][aNode->nodeY] = TILE_MARKED;
				aNode = aNode->parentNode;
			}
			return;
			//*****************************************//
		}
		else
		{
			//...otherwise, examine this node.
			//remove it from open list, add it to closed:
			[closedList addObject: currentNode];
			[openList removeObject: currentNode];
			
			//lets keep track of our coordinates:
			currentX = currentNode->nodeX;
			currentY = currentNode->nodeY;
			
			//check all the surrounding nodes/tiles:
			for(y=-1;y<=1;y++)
			{
				newY = currentY+y;
				for(x=-1;x<=1;x++)
				{
					newX = currentX+x;
					if(y || x) //avoid 0,0
					{						
						//simple bounds check for the demo app's array
						if((newX>=0)&&(newY>=0)&&(newX<20)&&(newY<20))
						{
							//if the node isn't in the open list...
							if(![self nodeInArray: openList withX: newX Y:newY])
							{
								//and its not in the closed list...
								if(![self nodeInArray: closedList withX: newX Y:newY])
								{
									//and the space isn't blocked
									if(![self spaceIsBlocked: newX :newY])
									{
										//then add it to our open list and figure out
										//the 'cost':
										aNode = [PathFindNode node];
										aNode->nodeX = newX;
										aNode->nodeY = newY;
										aNode->parentNode = currentNode;
										aNode->cost = currentNode->cost + 1;
										
										//Compute your cost here. This demo app uses a simple manhattan
										//distance, added to the existing cost
										aNode->cost += (abs((newX) - endX) + abs((newY) - endY));
										
										[openList addObject: aNode];
										
										if(animate) //demo animation stuff
											[self display];
									}
								}
							}
						}
					}
				}
			}
		}		
	}
	//**** NO PATH FOUND *****
	[[NSAlert alertWithMessageText: @"No Path Found" defaultButton:@"Darn" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Couldn't find a path from the start to end point."] runModal];
}

////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// End A* code/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

-(void)mouseDown:(NSEvent*)e
{
	[self mouseDragged: e];
}

-(void)mouseDragged:(NSEvent*)e
{
	NSPoint p = [e locationInWindow];
	NSPoint clickSpot = [self convertPoint: p fromView: nil];
	int x,y;
	x = clickSpot.x / 16;
	y = clickSpot.y / 16;
	tileMap[x][y] = currentTool;
	if(currentTool == TOOL_START)
	{
		sx = x;
		sy = y;

	}else if(currentTool == TOOL_FINISH)
	{
		ex = x;
		ey = y;
	}
	[self setNeedsDisplay: YES];
}

-(void)drawGrid:(NSArray*)openList
{
	int x,y;
	NSRect r;
	NSBezierPath *p = [NSBezierPath bezierPath];
	
	//Demo App - draw the various square colors and grid
	
	for(x=0;x<20;x++)
	{
		for(y=0;y<20;y++)
		{
			
			r = NSMakeRect(x*16,y*16,16,16);
			switch(tileMap[x][y])
			{
				case TILE_OPEN:
					[[NSColor whiteColor] set];
					break;
				case TILE_WALL:
					[[NSColor darkGrayColor] set];
					break;
				case TILE_START:
					[[NSColor greenColor] set];
					break;
				case TILE_FINISH:
					[[NSColor redColor] set];
					break;
				case TILE_MARKED:
					[[NSColor blueColor] set];
			}
			NSRectFill(r);
		}
	}
	
	//for live updates, examine the openList and highlight
	if(openList)
	{
		[[NSColor colorWithDeviceRed:.7 green:1.0 blue:.7 alpha:1.0] set];
		int i;
		for(i=0;i<[openList count];i++)
		{
			PathFindNode *n = [openList objectAtIndex: i];
			x = n->nodeX;
			y = n->nodeY;
			r = NSMakeRect(x*16,y*16,16,16);
			NSRectFill(r);
		}
	}
	
	for(x=0;x<20;x++)
	{
		[p moveToPoint: NSMakePoint(0,x*16+.5)];
		[p lineToPoint: NSMakePoint(500,x*16+.5)];
	}
	for(x=0;x<20;x++)
	{
		[p moveToPoint: NSMakePoint(x*16+.5,0)];
		[p lineToPoint: NSMakePoint(x*16+.5,500)];
	}
	[[NSColor lightGrayColor] set];
	[p stroke];
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	[self drawGrid: pointerToOpenList];
}

-(BOOL)acceptsFirstResponder
{
	return YES;
}


-(IBAction)showHelpInfo:(id)sender
{
	[[NSAlert alertWithMessageText: @"FindPathX" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"This app demonstrates a simple Obj-C based A-Star algorithm. To use the demo app, simply place a start point, an end point, and draw any solid walls that you would like. Then click Find Path."] runModal];
}
-(IBAction)quitDemo:(id)sender
{
	[NSApp terminate: nil];
}
-(IBAction)selectTool:(id)sender
{
	currentTool = [sender selectedTag];
}
-(void)resetGrid
{
	int x,y;
	for(x=0;x<20;x++)
	{
		for(y=0;y<20;y++)
		{
			tileMap[x][y] = TILE_OPEN;
		}
	}
	sx = sy = ex = ey = -1; //keep these out of bounds until needed
}
-(void)awakeFromNib
{
	//give us a demo starting map
	tileMap[3][3] = TILE_START;
	sx = 3; sy = 3;
	tileMap[17][8] = TILE_FINISH;
	ex = 17; ey = 8;
	
	int y;
	for(y=0;y<=17;y++)
	{
		tileMap[8][y] = TILE_WALL;
	}
	int x;
	for(x=2;x<=17;x++)
	{
		tileMap[x][10] = TILE_WALL;
	}
}
-(IBAction)clearMap:(id)sender
{
	//For demo app, clears the grid, redraws
	[self resetGrid];
	[self setNeedsDisplay: YES];
}
-(IBAction)runDemo:(id)sender
{
	//check to make sure our points are set
	if(
	   (sx<0) || (sy<0) || (sx>=20) || (sy >= 20) ||
	   (ex<0) || (ey<0) || (ex>=20) || (ey >= 20)
		)
	{
		return;
	}
		
	int x,y;
	for(x=0;x<20;x++)
	{
		for(y=0;y<20;y++)
		{
			if(tileMap[x][y] == TILE_MARKED)
				tileMap[x][y] = TILE_OPEN;
		}
	}
	
	[self findPath: sx :sy :ex :ey];
	pointerToOpenList = nil;
	[self setNeedsDisplay: YES];
}
@end
