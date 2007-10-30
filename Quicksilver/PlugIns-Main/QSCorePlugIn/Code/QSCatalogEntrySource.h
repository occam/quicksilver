

#import <Foundation/Foundation.h>
#import "QSObject.h"

#import "QSObjectSource.h"

@interface QSCatalogEntrySource : QSObjectSource {

}
- (NSArray *)objectsFromCatalogEntries:(NSArray *)catalogObjects;

- (NSArray *)childrenForObject:(QSBasicObject *)object;
@end
