#import <Foundation/Foundation.h>
#import <QSCore/QSRegistry.h>

#define kQSFSBrowserMediators @"QSFSBrowserMediators"
#define mQSFSBrowser (id <QSFSBrowserMediator>) [QSReg getMediator:kQSFSBrowserMediators]

@protocol QSFSBrowserMediator
- (NSImage *)icon;
- (void)revealFile:(NSString *)path;
- (NSArray *)selection;
- (NSArray *)getInfoForFiles:(NSArray *)files;
- (NSArray *)copyFiles:(NSArray *)files toFolder:(NSString *)destination;
- (NSArray *)moveFiles:(NSArray *)files toFolder:(NSString *)destination;
- (BOOL)openFile:(NSString *)file;
@end

@interface QSRegistry (QSFSBrowserMediator)
- (NSString *)FSBrowserMediatorID;
- (id <QSFSBrowserMediator>) FSBrowserMediator;
@end
