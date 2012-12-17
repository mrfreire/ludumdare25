//
//  MissionNotes.h
//  TheVault
//
//  Created by Manuel Freire on 16/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MissionNotes : CCLayer
{
    int level;
    BOOL goingToNextScreen;
}

+ (CCScene*)sceneWithLevel:(int)level;

@end
