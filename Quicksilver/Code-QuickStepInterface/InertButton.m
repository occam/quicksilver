//
//  InertButton.m
//  Quicksilver
//
//  Created by Alcor on Tue Apr 01 2003.
//  Copyright (c) 2003 Blacktree, Inc. All rights reserved.
//

#import "InertButton.h"


@implementation InertButton
- (BOOL)acceptsFirstResponder{
    return NO;
}
- (BOOL)mouseDownCanMoveWindow{
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent{
    [[self window] mouseDown:theEvent];
}


@end
