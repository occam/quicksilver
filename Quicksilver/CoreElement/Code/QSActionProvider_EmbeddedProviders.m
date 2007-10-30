

#import "NSPasteboard_BLTRExtensions.h"
#import "QSActionProvider_EmbeddedProviders.h"
#import "NSString+NDCarbonUtilities.h"
#import "NSAppleEventDescriptor+NDAppleScriptObject.h"
#import "QSObject.h"
#import "QSObject_FileHandling.h"

#import "NDAlias+AliasFile.h"
#import <Carbon/Carbon.h>

#import "QSController.h"
#import "NDAlias.h"

#import "QSSimpleWebWindowController.h"

#import "QSLoginItemFunctions.h"
#import "QSFSBrowserMediator.h"
#import "QSNullObject.h"
#import "QSObject_PropertyList.h"
#import "QSObject_StringHandling.h"
//#import "QSWebSearchController.h"
#import "QSTaskController.h"

#import "NDAppleScriptObject.h"
//#import "QSEditorController.h"
//#import "InstantMessaging.h"

#import "QSAlertManager.h"
#import "QSTypes.h"
#import "QSMacros.h"

#import "NSPasteboard_BLTRExtensions.h"
#import "QSFileConflictPanel.h"
#import "QSProcessSource.h"
#import "QSResourceManager.h"

#import "NSObject+ReaperExtensions.h"
#import <Carbon/Carbon.h>

#import "QSTextProxy.h"

#import "QSLibrarian.h"

#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>


#import "NSURL_BLTRExtensions.h"

# define kURLOpenAction @"URLOpenAction"
# define kURLOpenWithAction @"URLOpenWithAction"
# define kURLJSAction @"URLJSAction"
# define kURLEmailAction @"URLEmailAction"

#import "NSPasteboard_BLTRExtensions.h"

#import "QSLSTools.h"

@implementation URLActions
- (NSString *) defaultWebClient{
	
	NSURL *appURL = nil; 
	OSStatus err; 
	err = LSGetApplicationForURL((CFURLRef)[NSURL URLWithString: @"http:"],kLSRolesAll, NULL, (CFURLRef *)&appURL); 
	if (err != noErr) QSLog(@"error %ld", err); 
	// else QSLog(@"%@", appURL); 
	
	return [appURL path];
	
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	NSString *urlString=[dObject objectForType:QSURLType];
	
	NSMutableArray *newActions=[NSMutableArray arrayWithCapacity:1];
	if (urlString){
		if ([urlString hasPrefix:@"javascript:"]) return [NSArray arrayWithObject:kURLJSAction];
		if ([urlString hasPrefix:@"mailto:"]) return [NSArray arrayWithObject:kURLEmailAction];
		//	NSURL *url=[NSURL URLWithString:urlString];		
	} 
	[newActions addObject:kURLOpenAction];
	[newActions addObject:kURLOpenWithAction];
	
	return newActions;
}


- (QSObject *)doURLOpenAction:(QSObject *)dObject{
	
	NSMutableArray *urlArray=[NSMutableArray array];
	
	
	
	NSString *urlString;
	
	NSEnumerator *e=[[dObject arrayForType:QSURLType]objectEnumerator];
	
	while (urlString=[e nextObject]){
		NSURL *url=[NSURL URLWithString:urlString];
		
		if ([urlString rangeOfString:QUERY_KEY].location!=NSNotFound){
			int pathLoc=[urlString rangeOfString:[url path]].location;
			if (pathLoc!=NSNotFound)
				url=[NSURL URLWithString:[urlString substringWithRange:NSMakeRange(0,pathLoc)]];
		}
		
		url=[url URLByInjectingPasswordFromKeychain];
		if (url){
			[urlArray addObject:url];
		}else{
			QSLog(@"error with url: %@",urlString);
		}
	}
	
	if (fALPHA && ![QSAction modifiersAreIgnored] && mOptionKeyIsDown){
		id cont=[[NSClassFromString(@"QSSimpleWebWindowController") alloc]initWithWindow:nil];
		//QSLog(@"wind %@ %@",cont,[cont window]);
		[(QSSimpleWebWindowController *)cont openURL:[urlArray lastObject]];
		[[cont window]makeKeyAndOrderFront:nil];	
	}else{
		NSString *urlHandler=[dObject objectForMeta:@"QSPreferredApplication"];
		
		[[NSWorkspace sharedWorkspace] openURLs:urlArray withAppBundleIdentifier:urlHandler options:nil additionalEventParamDescriptor:nil launchIdentifiers:nil];		
		
	}
	
	return nil;
}




- (QSObject *)doURLOpenAction:(QSObject *)dObject with:(QSObject *)iObject {
	NSString *urlString=[dObject objectForType:QSURLType];
	
	NSURL *url=[NSURL URLWithString:urlString];
	url=[url URLByInjectingPasswordFromKeychain];
	NSString *ident=nil;
	if ([iObject isApplication])
		ident=[[NSBundle bundleWithPath:[iObject singleFilePath]]bundleIdentifier];
	if (ident)
		[[NSWorkspace sharedWorkspace]openURLs:[NSArray arrayWithObject:url]
					   withAppBundleIdentifier:ident
									   options:nil
				additionalEventParamDescriptor:nil
							 launchIdentifiers:nil
			];
	return nil;
}

- (QSObject *)doURLJSAction:(QSObject *)dObject{
	// NSURL *url=[NSURL URLWithString:[dObject primaryObject]];
	[self performJavaScript:[[dObject objectForType:QSURLType]URLDecoding]];
	return nil;
}


- (void) performJavaScript:(NSString *)jScript{
	NSString *key=[[NSUserDefaults standardUserDefaults] stringForKey:@"QSWebBrowserMediators"];
	if (!key)key=QSApplicationIdentifierForURL(@"javascript:");
	if (!key)key=QSApplicationIdentifierForURL(@"http:");
	
	id instance=[QSReg instanceForKey:key inTable:@"QSWebBrowserMediators"];
	
	//	QSLog(@"instance: %@ %@",instance,key);
	if ([instance respondsToSelector:@selector(performJavaScript:)])
		[instance performJavaScript:jScript];	
}

@end




# define kDiskEjectAction @"DiskEjectAction"
# define kDiskForceEjectAction @"DiskForceEjectAction"
@implementation FSDiskActions

- (NSArray *) actions{
	QSAction *action=[QSAction actionWithIdentifier:kDiskEjectAction];
	[action setIcon:[QSResourceManager imageNamed:@"EjectMediaIcon"]];
	[action setProvider:self];
	return [NSArray arrayWithObjects:action,nil];
	
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	NSWorkspace *workspace=[NSWorkspace sharedWorkspace];
	
	NSString *path=[dObject singleFilePath];
	
	if ([[workspace mountedLocalVolumePaths]containsObject:[path stringByStandardizingPath]]){
		return [NSArray arrayWithObject:kDiskEjectAction];
	}
	return nil;
}



- (QSObject *) performAction:(QSAction *)action directObject:(QSBasicObject *)dObject indirectObject:(QSBasicObject *)iObject{
	NSWorkspace *workspace=[NSWorkspace sharedWorkspace];
	NSString *firstFile=[dObject singleFilePath];
	if (![workspace unmountAndEjectDeviceAtPath:firstFile]){
		//NSBeep();
		NSString *displayName=[[NSFileManager defaultManager]displayNameAtPath:firstFile];
		NSAppleScript *ejectScript=[[[NSAppleScript alloc]initWithSource:[NSString stringWithFormat:@"tell application \"Finder\" to eject disk \"%@\"",displayName]]autorelease]; 
		//QSLog([NSString stringWithFormat:@"tell application \"Finder\" to eject disk \"%@\"",displayName]);
		NSDictionary *errorDict;
		[ejectScript executeAndReturnError:&errorDict];
		if (errorDict) NSBeep();
	}
	return nil;
}

@end



@implementation FSActions

- (NSArray *)universalApps { 
	if (!universalApps){
		[[QSTaskController sharedInstance] updateTask:@"Updating Application Database" status:@"Updating Applications"  progress:-1];
		
		NSString *path=[[NSBundle mainBundle]pathForResource:@"wildcard" ofType:@"*"];
		universalApps=(NSArray *)LSCopyApplicationURLsForURL((CFURLRef)[NSURL fileURLWithPath:path],kLSRolesAll);
		//QSLog(@"Universal Apps: %@\r%d",[universalApps valueForKeyPath:@"path.lastPathComponent"],[universalApps count]);
		[[QSTaskController sharedInstance] removeTask:@"Updating Application Database"];
		
	}
	[self performSelector:@selector(setUniversalApps:) withObject:nil afterDelay:10*MINUTES extend:YES];
	return universalApps;
}

- (void)setUniversalApps:(NSArray *)anUniversalApps{
	   if (universalApps != anUniversalApps) {
		   [universalApps release];
		   universalApps = [anUniversalApps retain];
	   }
}


- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	
	NSFileManager *manager=[NSFileManager defaultManager];
	NSMutableArray *validIndirects=[NSMutableArray arrayWithCapacity:1];
	

	if ([action isEqualToString:kFileOpenWithAction]){
		
		NSURL *fileURL=nil;
		if ([dObject singleFilePath])
			fileURL=[NSURL fileURLWithPath:[dObject singleFilePath]];
		NSURL *appURL=nil;
		
		if (fileURL) LSGetApplicationForURL((CFURLRef)fileURL,kLSRolesAll, NULL,(CFURLRef *)&appURL);
		
		//QSLog(@"%@",fileURL);
		//QSLog(@"%@",appURL);
		
		
		//if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Use LS for Open With"] && [dObject fileCount]==1){
		NSMutableSet *set=[NSMutableSet set];
		NSArray *apps=(NSArray *)LSCopyApplicationURLsForURL((CFURLRef)fileURL,kLSRolesAll);
		[apps autorelease];
		//			apps=[[apps mutableCopy]autorelease];
		[set addObjectsFromArray:apps];
		
		//	[set addObject:[QSSeparatorObject separator]];
		[set addObjectsFromArray:[self universalApps]];
		validIndirects=[QSObject fileObjectsWithURLArray:[set allObjects]];
		
		validIndirects=[QSLib scoredArrayForString:nil inSet:validIndirects];	
		
		id preferred=[QSObject fileObjectWithPath:[appURL path]];
		if (!preferred)preferred=[NSNull null];
		
		return [NSArray arrayWithObjects:preferred,validIndirects,nil];
		
		//		}else{
		//			NSArray *fileObjects=[QSLib arrayForType:QSFilePathType];
		//			int i;
		//			
		//			
		//			if ([appURL path])
		//				[validIndirects addObject:[QSObject fileObjectWithPath:[appURL path]]];
		//			
		//			
		//			if (1){
		//				[validIndirects addObjectsFromArray:fileObjects];
		//			}else{
		//				LSItemInfoRecord infoRec;
		//				for(i=0;i<[fileObjects count];i++){
		//					QSObject *thisObject=[fileObjects objectAtIndex:i];
		//					NSString *path=[thisObject singleFilePath];
		//					if (path){
		//						LSCopyItemInfoForURL((CFURLRef)[NSURL fileURLWithPath:path],
		//											 kLSRequestBasicFlagsOnly, &infoRec);
		//						if (infoRec.flags & kLSItemInfoIsApplication)
		//							[validIndirects addObject:thisObject];
		//					}
		//					
		//				}
		//			}
		//			return validIndirects;
		//		}
		
		
		
		/*
		 BOOL valid;
		 NSArray *appURLs = nil;
		 //LSInit(1);
		 _LSCopyAllApplicationURLs(&appURLs);
		 apps=[NSMutableArray arrayWithCapacity:[appURLs count]];
		 int i;
		 for (i=0;i<[appURLs count];i++){
			 LSCanURLAcceptURL(fileURL,[appURLs objectAtIndex:i],kLSRolesAll,kLSAcceptDefault,&valid);
			 if (valid){QSLog(@"url%@",[appURLs objectAtIndex:i]);   
				 [apps addObject:[appURLs objectAtIndex:i]];
			 }
			 */
		
		// QSLog(@"%@",apps);
		 }        
	if ([action isEqualToString:kFileRenameAction]){
		NSString *path=[dObject singleFilePath];
		if (path){
			
			QSObject *proxy=[QSObject textProxyObjectWithDefaultValue:[path lastPathComponent]];
			return [NSArray arrayWithObject:proxy];
		}
	}
	if ([action isEqualToString:@"QSNewFolderAction"]){
		QSObject *proxy=[QSObject textProxyObjectWithDefaultValue:@"untitled folder"];
		return [NSArray arrayWithObject:proxy];
		
	}
	
	if ([action isEqualToString:kFileMoveToAction]){
		NSArray *fileObjects=[QSLib arrayForType:QSFilePathType];
		BOOL isDirectory;   
		
		for(QSObject *thisObject in fileObjects){
			NSString *path=[thisObject singleFilePath];
			if ([manager fileExistsAtPath:path  isDirectory:&isDirectory]){
				if (isDirectory && ![[path pathExtension]length])
					[validIndirects addObject:thisObject];
			}
		}
		return validIndirects;
	}
	return nil;
	
	}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	// NSFileManager *manager=[NSFileManager defaultManager];
	NSArray *paths=[dObject validPaths];
	NSString *singlePath=[dObject validSingleFilePath];
	
	
	NSMutableArray *newActions=[NSMutableArray arrayWithCapacity:1];
	
	
	if (paths){
		//if (singlePath && [[NSArray arrayWithObjects:@"'APPL'",@"app",nil] containsObject:[[NSFileManager defaultManager] typeOfFile:singlePath]])
		//	[newActions addObject:kAppOpenFileAction];
		//else
		[newActions addObject:kFileOpenAction];
		
		[newActions addObject:kFileOpenWithAction];
		[newActions addObject:kFileRevealAction];
		[newActions addObject:kFileMakeLinkInAction];
		[newActions addObject:kFileDeleteAction];
		[newActions addObject:kFileToTrashAction];
		[newActions addObject:kFileMoveToAction];
		[newActions addObject:kFileCopyToAction];
		
		[newActions addObject:kFileGetInfoAction];
	}        
	
	if (singlePath){
		[newActions addObject:kFileRenameAction];
		
	}
	
	[newActions addObject:kFileGetPathAction];
	
	return newActions;
}


- (BOOL)filesExist:(NSArray *)paths{
	NSFileManager *manager=[NSFileManager defaultManager];
	
	NSString *thisFile;
	for(thisFile in paths)
		if (![manager fileExistsAtPath:thisFile])return NO;
	return YES;
}


- (QSObject *) openFile:(QSObject *)dObject{
	NSEnumerator *files=[[dObject validPaths]objectEnumerator];
	NSString *thisFile;
	NSFileManager *manager=[NSFileManager defaultManager];
	LSItemInfoRecord infoRec;
	while(thisFile=[files nextObject]){
		
		LSCopyItemInfoForURL((CFURLRef)[NSURL fileURLWithPath:thisFile],
							 kLSRequestBasicFlagsOnly, &infoRec);
		
		
		if (!(infoRec.flags & kLSItemInfoIsContainer) || (infoRec.flags & kLSItemInfoIsPackage)  ||  ![mQSFSBrowser openFile:thisFile]){
			
			
			if (infoRec.flags & kLSItemInfoIsAliasFile){ 
				NSString *aliasFile=[manager resolveAliasAtPathWithUI:thisFile];
				if (aliasFile && [manager fileExistsAtPath:aliasFile]){
					thisFile=aliasFile;
				}
			}
			
			NSString *fileHandler=[dObject objectForMeta:@"QSPreferredApplication"];
			if (fileHandler){
				if (VERBOSE)QSLog(@"Using %@",fileHandler);
				NSString *appPath=[[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:fileHandler];
				[[NSWorkspace sharedWorkspace] openFile:thisFile withApplication:appPath];
			}else{
				if (![QSAction modifiersAreIgnored] && (GetCurrentKeyModifiers()&shiftKey)){ // Open in background
					QSLog(@"Launching in Background");
					[[NSWorkspace sharedWorkspace] openFileInBackground:thisFile];  
				}else{
					[[NSWorkspace sharedWorkspace] openFile:thisFile];  
				}
			}
			
			
		}
	}
	return nil;
}
//alwaysOpenFile:with

- (QSObject *) alwaysOpenFile:(QSObject *)dObject with:(QSObject *)iObject{
//LSSetDefaultRoleHandlerForContentType
	FSRef ref;
	[[dObject singleFilePath] getFSRef:&ref];
	CFStringRef type;
	LSCopyItemAttribute(&ref,
						kLSRolesNone,
						kLSItemContentType,
						(CFTypeRef *)&type); 
	[(NSString *)type autorelease];
	NSString *bundleID=[[NSBundle bundleWithPath:[iObject singleFilePath]]bundleIdentifier];
	QSLog(@"type %@ -> %@",type,bundleID);	
	
//	LSSetDefaultRoleHandlerForContentType(type,
//										  kLSRolesAll,
//										  bundleID)     
	return nil;
}
- (QSObject *) openFile:(QSObject *)dObject with:(QSObject *)iObject{
	NSEnumerator *files=[[dObject validPaths]objectEnumerator];
	NSString *thisFile;
	if (![iObject isApplication]){
		NSBeep();
		return nil;
	}
	
	NSString *thisApp=[iObject singleFilePath];
	while(thisFile=[files nextObject])
		[[NSWorkspace sharedWorkspace] openFile:thisFile withApplication:thisApp];
	return nil;
}

- (QSObject *) makeFolderIn:(QSObject *)dObject named:(QSObject *)iObject{
	NSString *theFolder=[dObject validSingleFilePath];
	NSString *newPath=[theFolder stringByAppendingPathComponent:[iObject stringValue]];
	NSFileManager *fm=[NSFileManager defaultManager];
	
	[fm createDirectoryAtPath:newPath attributes:nil];
	[[NSWorkspace sharedWorkspace] noteFileSystemChanged:theFolder];
	
	return [QSObject fileObjectWithPath:newPath];
}



- (QSObject *) revealFile:(QSObject *)dObject{
	NSEnumerator *files=[[dObject validPaths]objectEnumerator]; 
	// ***warning   * should resolve aliases
	NSString *thisFile; //=[dObject singleFilePath];
	while(thisFile=[files nextObject])
		//QSLog(@"thisfile %@",thisFile);
		//if (thisFile)
		[mQSFSBrowser revealFile:thisFile];   
	return nil;
}

- (QSObject *) getInfo:(QSObject *)dObject{
	[[QSReg getMediator:kQSFSBrowserMediators]getInfoForFiles:[dObject validPaths]];   
	return nil;
}

- (QSBasicObject *) deleteFile:(QSObject *)dObject{
	NSArray *selection=[[dObject arrayForType:QSFilePathType]valueForKey:@"lastPathComponent"];
	
	// ***warning   * activate before showing
	NSWindow *interfaceWindow=[(NSWindowController *)[[NSApp delegate]interfaceController]window];    
	
	int choice = QSRunCriticalAlertSheet(interfaceWindow,@"Delete File",[NSString stringWithFormat:@"Are you sure you want to PERMANENTLY delete:\r %@?",[selection componentsJoinedByString:@", "]],@"Delete", @"Cancel",nil);
	
	//  int choice=NSRunInformationalAlertPanel();
	if (choice==1){
		NSEnumerator *files=[dObject enumeratorForType:QSFilePathType];
		NSString *thisFile;
		while(thisFile=[files nextObject]){
			if ([[NSFileManager defaultManager] removeFileAtPath:thisFile handler:nil])
				[[NSWorkspace sharedWorkspace] noteFileSystemChanged:[thisFile stringByDeletingLastPathComponent]];
			else
				QSLog(@"Could not delete file");
		}
	}
	return [QSObject nullObject];
}

- (QSBasicObject *) trashFile:(QSObject *)dObject{
	NSEnumerator *files=[[dObject arrayForType:QSFilePathType]objectEnumerator];
	NSString *thisFile;
	while(thisFile=[files nextObject]){
		[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
													 source:[thisFile stringByDeletingLastPathComponent]
												destination:@"" files:[NSArray arrayWithObject:[thisFile lastPathComponent]] tag:nil];
		
		[[NSWorkspace sharedWorkspace] noteFileSystemChanged:[thisFile stringByDeletingLastPathComponent]];
	}
	
	return [QSObject nullObject];
}


- (QSObject *) openItemAtLogin:(QSObject *)dObject{
	
	foreach(path,[dObject arrayForType:QSFilePathType]){
		QSSetItemShouldLaunchAtLogin(path,YES,YES);
	}
	
	return nil;
}


- (QSObject *) renameFile:(QSObject *)dObject withName:(QSObject *)iObject{
	NSString *path=[dObject singleFilePath];
	
	NSString *container=[path stringByDeletingLastPathComponent];
	
	// ***warning   * need to hide extension if needed
	
	NSString *newName=[iObject objectForType:QSTextType];
	
	
	
	if ([newName rangeOfString:@":"].location!=NSNotFound)newName=nil;
	
	// ***warning   * check the filesystem
	if (![[newName pathExtension]length] && [[path pathExtension]length]){
		newName=[newName stringByAppendingPathExtension:[path pathExtension]];
	}
	if (!newName){
		NSBeep();
		return nil;
	}
	
	newName=[newName stringByReplacing:@"/" with:@":"];
	
	NSString *destinationFile=[container stringByAppendingPathComponent:newName];
	
	if ([[NSFileManager defaultManager] movePath:path toPath:destinationFile handler:nil]){
		[[NSWorkspace sharedWorkspace] noteFileSystemChanged:container];
	} else {
		[[NSAlert alertWithMessageText:@"error" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Error renaming File: %@ to %@",path,destinationFile]runModal];
		
	}
	
	
	return [QSObject fileObjectWithPath:destinationFile];
}

- (QSObject *) duplicateFile:(QSObject *)dObject{
	return nil;
}



// ***warning   * these methods should default to using finder
- (QSObject *) moveFiles:(QSObject *)dObject toFolder:(QSObject *)iObject{return [self moveFiles:dObject toFolder:iObject shouldCopy:NO];}
- (QSObject *) copyFiles:(QSObject *)dObject toFolder:(QSObject *)iObject{return [self moveFiles:dObject toFolder:iObject shouldCopy:YES];}
- (QSObject *) moveFiles:(QSObject *)dObject toFolder:(QSObject *)iObject shouldCopy:(BOOL)copy{
	
	// QSLog(@"move %d",copy);
	NSString *destination=[iObject singleFilePath];
	NSArray *filePaths=[dObject validPaths];
	if (!filePaths)return nil;
	
	NSFileManager *manager=[NSFileManager defaultManager];
	NSDictionary *conflicts=[manager conflictsForFiles:filePaths inDestination:destination]; //originals:keys destin:values
	NSArray *resultPaths=nil;
	int copyMethod=QSReplaceFilesResolution;
	
	if (conflicts){
		NSMutableArray *otherFiles;
		QSLog(@"Conflicts: %@",conflicts);
		id panel=[QSFileConflictPanel conflictPanel];
		[panel setConflictNames:[conflicts allValues]];
		NSWindow *interfaceWindow=[(NSWindowController *)[[NSApp delegate]interfaceController]window];    
		copyMethod=[panel runModalAsSheetOnWindow:interfaceWindow];
		
		switch (copyMethod){
			case QSCancelReplaceResolution:
				return nil;
			case QSReplaceFilesResolution:
			{
				NSString *file;
				NSEnumerator *enumerator=[[conflicts allValues]objectEnumerator];
				while(file=[enumerator nextObject]){
					QSLog(file);
					[manager removeFileAtPath:file handler:nil];
				}
				break;
			}
			case QSDontReplaceFilesResolution:
				otherFiles=[[filePaths mutableCopy]autorelease];
				[otherFiles removeObjectsInArray:[conflicts allKeys]];
				
				if (DEBUG) QSLog(@"Only moving %@",otherFiles);
					filePaths=otherFiles;
				break;
			case QSSmartReplaceFilesResolution:
				break;
		}
	}
	
	// Try to copy using Finder
	
	
	if (copy)
		resultPaths=[mQSFSBrowser copyFiles:filePaths toFolder:destination]; 
	else
		resultPaths=[mQSFSBrowser moveFiles:filePaths toFolder:destination];
	
	if (resultPaths){
		if ([resultPaths count]<[filePaths count])
			QSLog(@"Finder-based move may not return all paths");
		return [QSObject fileObjectWithArray:resultPaths];
	}else{
		QSLog(@"Finder move failed");
	}
	
	
	// Copy using NSFileManager
	
	if (!resultPaths){
		if (DEBUG) QSLog(@"Using NSFileManager");
		NSMutableArray *newPaths=[NSMutableArray arrayWithCapacity:[filePaths count]];
		for(NSString *thisFile in filePaths){
			NSString *destinationFile=[destination stringByAppendingPathComponent:[thisFile lastPathComponent]];
			if (copy && [[NSFileManager defaultManager] copyPath:thisFile toPath:destinationFile handler:nil]){
				[newPaths addObject:destinationFile];
			}else if (!copy && [[NSFileManager defaultManager] movePath:thisFile toPath:destinationFile handler:nil]){
				[[NSWorkspace sharedWorkspace] noteFileSystemChanged:[thisFile stringByDeletingLastPathComponent]];
				[newPaths addObject:destinationFile];
			} else {
				[[NSAlert alertWithMessageText:@"Move Error" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Error Moving File: %@ to %@",thisFile,destination]runModal];
				
			}
		}
		[[NSWorkspace sharedWorkspace] noteFileSystemChanged:destination];
		return [QSObject fileObjectWithArray:newPaths];
	}
	
	return nil;
}








- (QSObject *) makeAliasTo:(QSObject *)dObject inFolder:(QSObject *)iObject{
	NSString *destination=[iObject singleFilePath];
	NSEnumerator *files=[dObject enumeratorForType:QSFilePathType];
	NSString *thisFile, *destinationFile;
	while(thisFile=[files nextObject]){
		destinationFile=[destination stringByAppendingPathComponent:[thisFile lastPathComponent]];
		if ([(NDAlias *)[NDAlias aliasWithPath:thisFile]writeToFile:destinationFile]){
			[[NSWorkspace sharedWorkspace] noteFileSystemChanged:destination];
		}
	}
	
	// ***warning   *  return [QSObject fileObjectWithPath:destinationFile];
	return nil;
}

- (QSObject *) makeLinkTo:(QSObject *)dObject inFolder:(QSObject *)iObject{
	// ***warning   * should warn
	
	NSString *destination=[iObject singleFilePath];
	NSEnumerator *files=[dObject enumeratorForType:QSFilePathType];
	NSString *thisFile, *destinationFile;
	
	while(thisFile=[files nextObject]){
		destinationFile=[destination stringByAppendingPathComponent:[thisFile lastPathComponent]];
		
		if ([[NSFileManager defaultManager] createSymbolicLinkAtPath:destinationFile pathContent:thisFile]){
			[[NSWorkspace sharedWorkspace] noteFileSystemChanged:destination];
		}
	}
	
	// ***warning   *  return [QSObject fileObjectWithPath:destinationFile];
	return nil;
}

- (QSObject *) makeHardLinkTo:(QSObject *)dObject inFolder:(QSObject *)iObject{
	// ***warning   * should warn
	
	NSString *destination=[iObject singleFilePath];
	NSEnumerator *files=[dObject enumeratorForType:QSFilePathType];
	NSString *thisFile, *destinationFile;
	
	while(thisFile=[files nextObject]){
		destinationFile=[destination stringByAppendingPathComponent:[thisFile lastPathComponent]];
		
		if ([[NSFileManager defaultManager] linkPath:destinationFile toPath:thisFile handler:nil]){
			[[NSWorkspace sharedWorkspace] noteFileSystemChanged:destination];
		}
	}
	
	// ***warning   *  return [QSObject fileObjectWithPath:destinationFile];
	return nil;
}


- (QSObject *) getFilePaths:(QSObject *)dObject{
	return [QSObject objectWithString:[[dObject arrayForType:QSFilePathType]componentsJoinedByString:@"\n"]];
}

- (QSObject *) getFileURLs:(QSObject *)dObject{
	NSArray *files=[dObject arrayForType:QSFilePathType];
	files=[NSURL performSelector:@selector(fileURLWithPath:) onObjectsInArray:files returnValues:YES];
	return [QSObject objectWithString:[files componentsJoinedByString:@"\n"]];
}

- (QSObject *) getFileLocations:(QSObject *)dObject{
	NSArray *files=[dObject arrayForType:QSFilePathType];
	files=[files arrayByPerformingSelector:@selector(fileSystemPathHFSStyle)];	
	return [QSObject objectWithString:[files componentsJoinedByString:@"\n"]];
}


@end


# define kAppLaunchAction @"AppLaunchAction"
# define kAppRootLaunchAction @"AppRootLaunchAction"
# define kAppLaunchAgainAction @"AppLaunchAgainAction"
@implementation AppActions



- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	//NSFileManager *manager=[NSFileManager defaultManager];
	// NSString *path=[dObject singleFilePath];
	NSMutableArray *newActions=[NSMutableArray arrayWithCapacity:1];
	
	
	// ***warning   * this doesn't see the character palette
	BOOL isRunning=(int)[dObject objectForType:QSProcessType];
	//QSLog(@"%@ %@",path,[[NSFileManager defaultManager] typeOfFile:path]);
	
	
	if (!isRunning){
		[newActions addObject:kAppLaunchAction];
	}
	return newActions;
}

@end


/*
# define kQSEditAction @"QSEditAction"
@implementation EditorActions
- (NSArray *) types{return [NSArray arrayWithObject:NSFilenamesPboardType];}
- (NSArray *) fileTypes{return [NSArray arrayWithObjects:@"'TEXT'",@"txt",@"rtf",@"rtfd",nil];}
- (NSArray *) actions{
	return [NSArray arrayWithObjects:
		[QSAction actionWithIdentifier:kQSEditAction
								  name:nil
								  icon:nil
							  provider:self
								action:nil
						 argumentCount:1
							   reverse:NO
			],
		nil];
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	return [NSArray arrayWithObject:kQSEditAction];
	return nil;
}

- (QSObject *) performAction:(QSAction *)action directObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	if ([action isEqualToString:kQSEditAction]){
		QSEditorController *editor=[[QSEditorController editorForObject:dObject]retain];
		[editor showWindow:self];
		
		[NSApp activateIgnoringOtherApps:YES];
		[[editor window]makeKeyAndOrderFront:self];
	}    
	return nil;
}

@end
*/


# define kPasteboardPasteAction @"PasteboardPasteAction"
# define kPasteboardExpandAction @"PasteboardExpandAction"

@implementation ClipboardActions

- (QSObject *) copyObject:(QSObject *)dObject{
	[dObject putOnPasteboard:[NSPasteboard generalPasteboard]];
	return nil;
}
- (QSObject *) pasteObject:(QSObject *)dObject{
	if([dObject putOnPasteboard:[NSPasteboard generalPasteboard]]){
		[[NSNotificationCenter defaultCenter] postNotificationName:@"WindowsShouldHide" object:self];
		[[NSApp keyWindow]orderOut:self];
		
		QSForcePaste();
	}
	else NSBeep();
	return nil;
}
@end
