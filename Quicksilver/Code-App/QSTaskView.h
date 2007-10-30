//
//  QSTaskView.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 11/26/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class QSTask;

@interface QSTaskView : NSView {
	IBOutlet QSTask *task;
	IBOutlet NSProgressIndicator *progress;
}
- (QSTask *)task;
- (void)setTask:(QSTask *)newTask;

@end
