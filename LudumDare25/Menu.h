//
//  Menu.h
//  LudumDare25
//
//  Created by Manuel Freire on 15/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameProgress.h"

@interface Menu : CCLayer {
    BOOL goingToGame;
    GameProgress progress;
}

+ (CCScene *) scene;

@end
