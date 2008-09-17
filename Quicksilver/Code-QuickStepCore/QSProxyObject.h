//
//  QSProxyObject.h
//  Quicksilver
//
//  Created by Alcor on 1/16/05.
//  Copyright 2005 Blacktree. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QSCore/QSObject.h>

#define kQSProxyProvider @"provider"
#define kQSProxyProviderClass @"providerClass"
#define kQSProxyTypes @"types"
#define kQSProxyIdentifier @"identifier"

#define QSProxyType @"qs.proxy"

#define QSProxyTargetCache @"proxyTarget"

@protocol QSProxyObjectProvider
- (BOOL)bypassValidation;
- (id)resolveProxyObject:(id)proxy;
- (NSArray *)typesForProxyObject:(id)proxy;
- (NSTimeInterval)cacheTimeForProxy:(id)proxy;
@end

@interface QSProxyObject : QSObject
+ (id)proxyWithDictionary:(NSDictionary*)dictionary;
- (NSObject <QSProxyObjectProvider> *)proxyProvider;
- (QSObject*)proxyObject;

- (void)releaseProxy;

- (BOOL)bypassValidation;
- (NSArray *)proxyTypes;
//- (id)proxyObjectWithProviderClass:(NSString *)providerClass;

@end


@interface QSGlobalSelectionProxyProvider : NSObject
- (QSObject *)proxy;
@end
