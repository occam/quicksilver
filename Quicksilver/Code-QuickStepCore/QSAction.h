#import <Foundation/Foundation.h>
#import <QSCore/QSObject.h>
#import <QSCore/QSObjectRanker.h>

// strings:
#define kActionClass @"actionClass"
#define kActionProvider @"actionProvider"
#define kActionSelector @"actionSelector"
#define kActionSendMessageToClass @"actionSendToClass"
#define kActionAlternate @"alternateAction"
#define kActionScript @"actionScript"
#define kActionHandler @"actionHandler"
#define kActionEventClass @"actionEventClass"
#define kActionEventID @"actionEventID"

#define kActionArgumentCount @"argumentCount" // Number, if undefined, calculates from selector

// strings:
#define kActionIcon @"icon"
#define kActionName @"name"
#define kActionUserData @"userData"
#define kActionEnabled @"enabled"
#define kActionIdentifier @"id"

// arrays:
#define kActionDirectTypes @"directTypes"
#define kActionIndirectTypes @"indirectTypes"
#define kActionResultType @"resultTypes"

// BOOLs:
#define kActionRunsInMainThread @"runInMainThread"
#define kActionDisplaysResult @"displaysResult"
#define kActionIndirectOptional @"indirectOptional"
#define kActionReverseArguments @"reverseArguments"
#define kActionSplitPluralArguments @"splitPlural"
#define kActionValidatesObjects @"validatesObjects"

// NSNumber (float) :
#define kActionPrecedence @"precedence"

@interface QSAction : QSObject {
	int rank;
}
#if 0
+ (void)setModifiersAreIgnored:(BOOL)flag;
+ (BOOL)modifiersAreIgnored;
#endif

+ (id)actionWithDictionary:(NSDictionary *)dict;
+ (id)actionWithDictionary:(NSDictionary *)dict identifier:(NSString *)ident;
+ (id)actionWithIdentifier:(NSString *)newIdentifier;

- (id)initWithDictionary:(NSDictionary *)dict identifier:(NSString *)ident bundle:(NSBundle *)bundle;

- (QSObject *)performOnDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject;

- (QSAction *)alternate;

- (id)provider;
- (void)setProvider:(id)newProvider;
- (void)setAction:(SEL)newAction;

- (int)rank;
- (void)setRank:(int)newRank;
- (float)precedence;
- (BOOL)enabled;
- (void)setEnabled:(BOOL)flag;
- (BOOL)menuEnabled;
- (void)setMenuEnabled:(BOOL)flag;
- (BOOL)defaultEnabled;

- (int)argumentCount;
- (void)setArgumentCount:(int)newArgumentCount;
- (BOOL)reverse;
- (void)setReverse:(BOOL)flag ;
- (BOOL)canThread;
- (BOOL)indirectOptional;
- (void)setIndirectOptional:(BOOL)flag;
- (BOOL)displaysResult;
- (void)setDisplaysResult:(BOOL)flag;

- (NSString *)commandFormat;
@end

@interface QSActionHandler : NSObject
@end
