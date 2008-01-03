/* QSController */


//#import <Cocoa/Cocoa.h>

@class QSObjectView;
@class QSActionMatrix;

@class QSWindow;
@class QSMenuWindow;
//@class QSPrefsController;
@class QSObject;

@class QSInterfaceController;
@class QSCatalogController;
//@class QSProcessSwitcher;


@interface QSController : NSWindowController {
    QSInterfaceController *interfaceController;
   // QSProcessSwitcher *switcherController;
    //QSPrefsController *prefsController;
    QSCatalogController *catalogController;
    NSWindowController *aboutWindowController;
    NSWindowController *quitWindowController;
    NSWindowController *triggerEditor;
    
    NSStatusItem *statusItem;
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSMenuItem *preferencesMenu;
    IBOutlet NSWindow *aboutWindow;
    IBOutlet NSTextField *versionField;
    
    NSConnection *controllerConnection; 
    NSConnection *contextConnection;
    NSWindow *splashWindow;
	
    BOOL newVersion;
    BOOL runningSetupAssistant;
    
    NSColor *iconColor;
	NSImage *activatedImage;
	NSImage *runningImage;
	NSConnection *dropletConnection;
	
	NSObject *dropletProxy;
}

- (IBAction)showElementsViewer:(id)sender;
- (IBAction)runSetupAssistant:(id)sender;
- (NSProgressIndicator *)progressIndicator;
- (IBAction)showPreferences:(id)sender;
- (IBAction)showGuide:(id)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)showCatalog:(id)sender;
- (IBAction)showTriggers:(id)sender;
- (IBAction)showAbout:(id)sender;
- (IBAction)showForums:(id)sender;
- (IBAction)openIRCChannel:(id)sender;
- (IBAction)donate:(id)sender;

- (IBAction)showTaskViewer:(id)sender;
- (IBAction)showReleaseNotes:(id)sender;

- (IBAction)showHelp:(id)sender;
- (IBAction)getMorePlugIns:(id)sender;

- (void)openURL:(NSURL *)url;
- (void)showSplash:sender;

- (void)recompositeIconImages;

- (NSImage *)daedalusImage;

- (void)activateDebugMenu;

- (NSMenu *)statusMenu;
- (NSMenu *)statusMenuWithQuit;


-(void) activateInterface:(id)sender;
-(void)checkForFirstRun;
- (IBAction) rescanItems:sender;
- (IBAction) forceRescanItems:sender;


- (void)receiveObject:(QSObject *)object;
- (IBAction)unsureQuit:(id)sender;
- (QSInterfaceController *)interfaceController;
- (void)setInterfaceController:(QSInterfaceController *)newInterfaceController;


- (NSMenu *)statusMenu;
- (NSColor *)iconColor;
- (void)setIconColor:(NSColor *)newIconColor;

- (void)startMenuExtraConnection;
- (IBAction)showAgreement:(id)sender;
- (void)setupAssistantCompleted:(id)sender;

- (IBAction)runSetupAssistant:(id)sender;
- (IBAction)reportABug:(id)sender;
- (NSImage *)activatedImage;
- (void)setActivatedImage:(NSImage *)newActivatedImage;
- (NSImage *)runningImage;
- (void)setRunningImage:(NSImage *)newRunningImage;
- (NSObject *)dropletProxy;
- (void)setDropletProxy:(NSObject *)newDropletProxy;

@end


@interface QSController (ErrorHandling)
- (void)registerForErrors;
@end



extern QSController *QSCon;