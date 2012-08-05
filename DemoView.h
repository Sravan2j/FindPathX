//
//  DemoView.h
//  FindPathX
//
//  Created by Matt on 9/5/08.
// UPDATE:
// 12/2/11 - This code was written quite some time ago and is a little messy in parts and could use
// a little improvement. However you may use this code however you like. Hopefully it will be useful
// to anyone looking to add A* to their ObjC apps. -Matt
// Copyright © 2008 by Matthew Reagan
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Cocoa/Cocoa.h>

#define TILE_OPEN 0
#define TILE_WALL 1
#define TILE_START 2
#define TILE_FINISH 3
#define TILE_MARKED 4 //painted blue to show the path once its computed

#define TOOL_OPEN 0
#define TOOL_WALL 1
#define TOOL_START 2
#define TOOL_FINISH 3

@interface DemoView : NSView {
	unsigned char tileMap[20][20]; //simple map grid used for the demo
	int currentTool; //keeps track of what tile we're drawing
	int sx,sy,ex,ey; //holds our start and end points
	
	NSMutableArray *pointerToOpenList;
	IBOutlet NSButton *shouldAnimateButton;
}
-(IBAction)showHelpInfo:(id)sender;
-(IBAction)quitDemo:(id)sender;
-(IBAction)selectTool:(id)sender;
-(IBAction)clearMap:(id)sender;
-(IBAction)runDemo:(id)sender;
-(void)drawGrid:(NSArray*)openList;
@end
