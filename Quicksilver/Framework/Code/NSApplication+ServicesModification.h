//
//  NSApplication+ServicesModification.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 12/16/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSApplication (ServicesModification) 
- (void)setKeyEquivalent:(NSString *)equiv forService:(NSString *)serviceName;
- (NSString *)keyEquivalentForService:(NSString *)serviceName;
- (NSDictionary *)servicesDictionaryForService:(NSString *)serviceName;
- (void)setServicesDictionary:(NSDictionary *)dict forService:(NSString *)serviceName;
@end
