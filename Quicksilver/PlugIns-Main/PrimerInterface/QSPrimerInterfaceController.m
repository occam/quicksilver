#import "QSPrimerInterfaceController.h"

#import <Carbon/Carbon.h>
#import <QSFoundation/QSFoundation.h>
#import <QSEffects/QSWindow.h>

#import <IOKit/IOCFBundle.h>
#import <ApplicationServices/ApplicationServices.h>


#define DIFF 84

NSRect alignRectInRect(NSRect innerRect,NSRect outerRect,int quadrant);

@implementation QSPrimerInterfaceController


- (id)init {
    self = [super initWithWindowNibName:@"Primer"];
    if (self) {
		
    }
    return self;
}

- (void) windowDidLoad{
	[super windowDidLoad];
	// logRect([[self window]frame]);
	[[self window] addInternalWidgetsForStyleMask:NSUtilityWindowMask closeOnly:YES];
    [[self window] setLevel:NSModalPanelWindowLevel];
    [[self window] setFrameAutosaveName:@"PrimerInterfaceWindow"];
    
	//  [[self window]setFrame:constrainRectToRect([[self window]frame],[[[self window]screen]visibleFrame]) display:NO];
	//    [(QSWindow *)[self window]setHideOffset:NSMakePoint(0,-99)];
	//   [(QSWindow *)[self window]setShowOffset:NSMakePoint(0,99)];
    [[self window]setHasShadow:YES];
	
	QSWindow *window=[self window];
    [window setHideOffset:NSMakePoint(0,0)];
    [window setShowOffset:NSMakePoint(0,0)];
    
	[dSelector setResultsPadding:2];
	[aSelector setResultsPadding:2];
	[iSelector setResultsPadding:2];
	//	[window setFastShow:YES];
	[window setShowEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSVExpandEffect",@"transformFn",@"show",@"type",[NSNumber numberWithFloat:0.15],@"duration",nil]];
	//	[window setHideEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSShrinkEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:.25],@"duration",nil]];
	
	[window setWindowProperty:[NSDictionary dictionaryWithObjectsAndKeys:@"QSExplodeEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:0.2],@"duration",nil]
					   forKey:kQSWindowExecEffect];
	
	[window setWindowProperty:[NSDictionary dictionaryWithObjectsAndKeys:@"hide",@"type",[NSNumber numberWithFloat:0.15],@"duration",nil]
					   forKey:kQSWindowFadeEffect];
	
	[window setWindowProperty:[NSDictionary dictionaryWithObjectsAndKeys:@"QSVContractEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:0.333],@"duration",nil,[NSNumber numberWithFloat:0.25],@"brightnessB",@"QSStandardBrightBlending",@"brightnessFn",nil]
					   forKey:kQSWindowCancelEffect];
	
	
	//  standardRect=[[self window]frame],[[NSScreen mainScreen]frame]);
	
	// [setHidden:![NSApp isUIElement]];
    
	
	// [[[self window] _borderView]_resetDragMargins];
	//  */
	//   [self contractWindow:self];
}

- (void)updateViewLocations{
    [super updateViewLocations];
	//   [[[self window]contentView]display];
}


- (void)hideMainWindow:(id)sender{
	
    [[self window] saveFrameUsingName:@"PrimerInterfaceWindow"];
    
    [super hideMainWindow:sender];
}

- (void)showMainWindow:(id)sender{
	NSRect frame=[[self window]frame];
	frame=constrainRectToRect(frame,[[[self window]screen]frame]);
	[[self window]setFrame:frame display:YES];
	
	if (defaultBool(@"QSAlwaysCenterInterface")){
		NSRect frame=[[self window]frame];
		frame=centerRectInRect(frame,[[[self window]screen]frame]);
		[[self window]setFrame:frame display:YES];	
	}
	
	[super showMainWindow:(id)sender];	
}
- (NSSize)maxIconSize{
    return NSMakeSize(128,128);
}
- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect{
    //
    return NSOffsetRect(NSInsetRect(rect,8,0),0,0);
    //return NSMakeRect(0,0,NSWidth(rect),0);
}




- (void)hideIndirectSelector:(id)sender{
    //[super hideIndirectSelector:sender];
	
	[indirectView setHidden:YES];
	
    [self resetAdjustTimer];  
}


- (void)showIndirectSelector:(id)sender{
	
	if ([indirectView isHidden]){
		[indirectView setOpacity:0.0];
		[indirectView setHidden:NO];
		
		//  [super showIndirectSelector:sender];
		
		[self resetAdjustTimer];
	}
}

- (void)expandWindow:(id)sender{ 
	//return nil;
    NSRect expandedRect=[[self window]frame];
    
	// float diff=28;
    expandedRect.size.height+=DIFF;
    expandedRect.origin.y-=DIFF;
	constrainRectToRect(expandedRect,[[[self window]screen]frame]);
	if (!expanded)
		[[self window]setFrame:expandedRect display:YES animate:YES];
    [super expandWindow:sender];
	[indirectView setOpacity:1.0];
}

- (void)contractWindow:(id)sender{
	
    NSRect contractedRect=[[self window]frame];
    
    contractedRect.size.height-=DIFF;
    contractedRect.origin.y+=DIFF;
	//   NSLog(@"expnded? %d",expanded);
    if (expanded)
        [[self window]setFrame:contractedRect display:YES animate:YES];
    
    [super contractWindow:sender];
}


- (void)searchObjectChanged:(NSNotification*)notif{
	[super searchObjectChanged:notif];	
	//	[self updateDetailsString];
	NSString *command=[[self currentCommand]description];
	if (!command)command=@"";
	[commandView setStringValue:[dSelector objectValue]?command:@"Begin typing in the Subject field to search"];
	
	//	[executeButton setEnabled:command!=nil];
	return nil;
}

-(void)updateDetailsString{
	NSString *command=[[self currentCommand]description];
	[commandView setStringValue:command?command:@""];
	return nil;
	NSResponder *firstResponder=[[self window]firstResponder];
	if ([firstResponder respondsToSelector:@selector(objectValue)]){
		id object=[firstResponder objectValue];
		if ([object respondsToSelector:@selector(details)]){
			NSString *string=[object details];
			if (string){
				[commandView setStringValue:string];
				return;
			}
		}
	}
	[commandView setStringValue:[[self currentCommand]description]];
}
-(void)searchView:(QSSearchObjectView *)view changedString:(NSString *)string{
	//	NSLog(@"string %@ %@",string,view);	
	
	if (string){
		if (view==dSelector)
			[dSearchText setStringValue:string];
		if (view==aSelector)
			[aSearchText setStringValue:string];
		if (view==iSelector)
			[iSearchText setStringValue:string];
		
	}
}
-(void)searchView:(QSSearchObjectView *)view changedResults:(NSArray *)array{
	//	NSLog(@"string %@ %@",string,view);	
	int count=[array count];
	NSString *string=[NSString stringWithFormat:@"%@ %@%@",count?[NSNumber numberWithInt:count]:@"No",view==aSelector?@"action":@"item",ESS(count)];
	//if (!count)string=@"No items";
	if (string){
		if (view==dSelector)
			[dSearchCount setStringValue:string];
		if (view==aSelector)
			[aSearchCount setStringValue:string];
		if (view==iSelector)
			[iSearchCount setStringValue:string];
		
	}
}

-(void)searchView:(QSSearchObjectView *)view resultsVisible:(BOOL)resultsVisible{
	if (view==dSelector)
		[dSearchResultDisclosure setState:resultsVisible];
	if (view==aSelector)
		[aSearchResultDisclosure setState:resultsVisible];
	if (view==iSelector)
		[iSearchResultDisclosure setState:resultsVisible];
}


@end
















