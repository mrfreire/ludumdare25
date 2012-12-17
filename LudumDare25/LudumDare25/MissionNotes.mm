//
//  MissionNotes.m
//  TheVault
//
//  Created by Manuel Freire on 16/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MissionNotes.h"

#import "GameScene.h"
#import "Menu.h"
#import "SimpleAudioEngine.h"

@implementation MissionNotes

+ (CCScene*)sceneWithLevel:(int)level
{
	CCScene* scene = [CCScene node];
	
	MissionNotes* layer = [[[MissionNotes alloc] initWithLevel:level] autorelease];
	
	[scene addChild:layer];
	
	return scene;
}

- (id)initWithLevel:(int)level_
{
    self = [super init];
	if (self) {
        level = level_;

        const char* levelTitles[] = {
            "ACT 1: STEALTH",
            "ACT 2: LIGHTS",
            "ACT 3: DOORS",
            "ACT 4: KILL",
            "ACT 5: BARBADOS"
        };
        
        const char* levelNotes[] = {
            "\
            1. Break into the bank's vault\n\
            2. Must avoid being seen by the guards\n\
            3. To open the vault door, press and hold SPACE\n\
            4. Escape with all the money before getting caught\n\
            ",
            "\
            1. Guards cannot see in the dark areas\n\
            2. Switch off the bank's lights by pressing SPACE\n\
            3. Open the vault and escape with the money before getting caught\n\
            ",
            "\
            1. Open and close the bank's doors by pressing SPACE\n\
            2. Escape with all the money before getting caught\n\
            ",
            "\
            1. It's wasn't possible to escape through this exit and now the guards are everywhere!\n\
            2. There's a knife in this room. I can use it by pressing K...\n\
            3. Escape!\n\
            ",
            "\
            1. This is the final job\n\
            2. Escape with all the money and retire to Barbados\n\
            "
        };
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];

        CCLabelTTF *labelPause = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%s", levelTitles[level-1]]
                                                    fontName:@"Impact"
                                                    fontSize:60];
        labelPause.position = ccp(screenSize.width/2, screenSize.height*2/3);
        [self addChild:labelPause];
        
        CCLabelTTF *labelPause2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%s", levelNotes[level-1]]
                                                     fontName:@"Impact"
                                                     fontSize:24];
        labelPause2.anchorPoint = ccp(0.5, 1);
        labelPause2.position = ccp(screenSize.width/2, screenSize.height*2/3*0.8);
        [self addChild:labelPause2];
        
        self.isKeyboardEnabled = YES;
	}
	return self;
}

- (void)goToLevel
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene sceneWithLevel:level]]];
}

- (BOOL)ccKeyDown:(NSEvent*)event
{
	NSString* character = [event characters];
    unichar keyCode = [character characterAtIndex:0];
    
    if (goingToNextScreen) {
        return NO;
    }
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"key.wav"];

    goingToNextScreen = true;
    
    if (keyCode == 27) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[Menu scene]]];
    } else {
        [self goToLevel];
    }

    return NO;
}

@end
