

#import "QSRankedObject.h"

@implementation QSRankedObject
/*+ (NSMutableArray *)rankedArrayWithObjects:(id *)objects scores:(float *)scores strings:(id *)strings count:(int)count {
    NSMutableArray *rankedArray = [NSMutableArray arrayWithCapacity:count];
    int i;
    for (i = 0; i<count; i++) {
        NSString *matched = strings[i];
        NSLog(@"rai %@ %@", objects[i] , [matched retain]);
        [rankedArray addObject: [[QSRankedObject alloc] initWithObject:objects[i] score:scores[i] string:nil]];
    }
    [rankedArray makeObjectsPerformSelector:@selector(release)];
    return rankedArray;
}*/

#pragma mark -
#pragma mark Forwarding machinery
- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector] || [object respondsToSelector:aSelector])
        return YES;
    return NO;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
	// NSLog(@"forward %@", invocation);
	if ([object respondsToSelector:[invocation selector]])
		[invocation invokeWithTarget:object];
	else
		[self doesNotRecognizeSelector:[invocation selector]];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)sel {
	NSMethodSignature *sig = [object methodSignatureForSelector:sel];
	if (!sig)
        sig = [[self class] instanceMethodSignatureForSelector:sel];
	return sig;
}

#pragma mark Lifecycle
- (id)initWithObject:(id)newObject matchString:(NSString *)matchString order:(int)newOrder score:(float)newScore {
    if (!newObject)
        [NSException raise:NSInvalidArgumentException
                    format:@"object can't be nil"];
	if (self = [super init]) {
		object = [newObject retain];
		order = newOrder;
		score = newScore;
		rankedString = [matchString retain];

	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [self initWithObject:[coder decodeObjectForKey:@"object"]
				 matchString:[coder decodeObjectForKey:@"string"]
						order:[coder decodeIntForKey:@"order"]
						score:[coder decodeFloatForKey:@"score"]];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:object forKey:@"object"];
	[coder encodeObject:rankedString forKey:@"string"];
	[coder encodeFloat:score forKey:@"score"];
}

- (void)dealloc {
	[object release];
	[rankedString release];
	[super dealloc];
}

- (NSString *)description {return [NSString stringWithFormat:@"[%@ %f] ", object, score];}

#pragma mark Comparison/Equality
- (NSComparisonResult) scoreCompare:(QSRankedObject *)compareObject {
	if (order == compareObject->order) {
        
		if (score > compareObject->score)
			return NSOrderedAscending;
		else if (score < compareObject->score)
			return NSOrderedDescending;
        
	} else {
		return order - compareObject->order;
	}
    
	return [self nameCompare:compareObject];
}


- (NSComparisonResult)nameCompare:(QSRankedObject *)compareObject {
	return [object nameCompare:compareObject->object];
}

- (NSComparisonResult)smartCompare:(QSRankedObject *)compareObject {
	if (score >= 1.0 || compareObject->score >= 1.0) return [self scoreCompare:compareObject];
	else return [object nameCompare:compareObject->object];
}

- (BOOL)isEqual:(id)anObject {
	return [anObject isEqual:object];
}

#pragma mark Accessors

- (float)score { return score; }
- (void)setScore:(float)newScore { score = newScore; }

- (int)order { return order;  }
- (void)setOrder:(int)newOrder { order = newOrder; }

- (id)object { return object; }
- (void)setObject:(id)newObject {
    if( newObject != object ) {
        [object release];
        object = [newObject retain];
    }
}

- (NSString *)rankedString { return rankedString;  }
- (void)setRankedString:(NSString *)newRankedString {
    if( newRankedString != rankedString ) {
        [rankedString release];
        rankedString = [newRankedString retain];
    }
}

/*- (BOOL)enabled {return [object enabled];}*/

/*- (NSString *)displayName {
	// if (rankedString) NSLog(@"rao %@", rankedString);
	if (rankedString) return rankedString;
	return [object displayName];
}*/

/*- (id)valueForKey:(NSString *)key {
	return [object valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key {
	[object setValue:value forKey:key];
}*/

- (NSMenu *)rankMenuWithTarget:(NSView *)target {
	NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"RankMenu"] autorelease];

	NSMenuItem *item;

	int myOrder = [self order];
	NSString *title = [NSString stringWithFormat:@"Score: %.0f", [self score] *100];
	if (myOrder != NSNotFound)
		title = [NSString stringWithFormat:@"Rank: %d, %@", myOrder+1, title];

	item = (NSMenuItem *)[menu addItemWithTitle:title action:NULL keyEquivalent:@""];
	[item setTarget:nil];
	[menu addItem:[NSMenuItem separatorItem]];

	if (myOrder != 0) {
		item = (NSMenuItem *)[menu addItemWithTitle:@"Make Default" action:@selector(defineMnemonicImmediately:) keyEquivalent:@""];
		[item setTarget:target];
	} else {
		item = (NSMenuItem *)[menu addItemWithTitle:@"Remove Default" action:@selector(removeMnemonic:) keyEquivalent:@""];
		[item setTarget:target];
	}
	//[self mnemo
	item = (NSMenuItem *)[menu addItemWithTitle:@"Decrease Score" action:@selector(clearMnemonics:) keyEquivalent:@""];
	[item setTarget:target];



	return menu;
}
@end
