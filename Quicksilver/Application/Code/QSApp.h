

#import <Foundation/Foundation.h>


#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

extern NSString * QSApplicationDidFinishLaunchingNotification;
extern BOOL QSApplicationCompletedLaunch;

@interface QSApp : NSApplication {
    int featureLevel;
    BOOL isUIElement;
    BOOL shouldRelaunch;
	IBOutlet NSMenu *hiddenMenu;
	NSResponder *globalKeyEquivalentTarget;
	NSMutableArray *eventDelegates;
}

- (int) featureLevel;

- (BOOL) isUIElement;
- (BOOL) setShouldBeUIElement:(BOOL)hidden; //Returns YES if successful
- (void) forwardWindowlessRightClick:(NSEvent *) theEvent;
- (BOOL) completedLaunch;
- (BOOL) isPrerelease;
- (NSResponder *) globalKeyEquivalentTarget;
- (void) setGlobalKeyEquivalentTarget:(NSResponder *)value;
- (void) addEventDelegate:(id)eDelegate;
- (void) removeEventDelegate:(id)eDelegate;
@end
