//
//  QSVolumesObjectSource.h
//  Quicksilver
//
//  Created by Alcor on 4/5/05.
//  Copyright 2005 Blacktree. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#import <QSCore/QSObjectSource.h>
@interface QSVolumesObjectSource : QSObjectSource{
    NSTimeInterval lastMountDate;
}
@end
