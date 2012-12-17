//
//  MissionSummary.m
//  TheVault
//
//  Created by Manuel Freire on 16/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MissionSummary.h"

#import "MissionNotes.h"
#import "Menu.h"
#import "SimpleAudioEngine.h"

@implementation MissionSummary

+ (CCScene*)sceneWithLevel:(int)level time:(int)seconds
{
	CCScene* scene = [CCScene node];
	
	MissionSummary* layer = [[[MissionSummary alloc] initWithLevel:level time:seconds] autorelease];
	
	[scene addChild:layer];
	
	return scene;
}

- (id)initWithLevel:(int)level_ time:(int)seconds
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
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF *labelPause = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%s", levelTitles[level-1]]
                                                    fontName:@"Impact"
                                                    fontSize:60];
        labelPause.position = ccp(screenSize.width/2, screenSize.height*2/3);
        [self addChild:labelPause];
        
        CCLabelTTF *labelPause2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"COMPLETED IN %02d:%02d", seconds/60, seconds%60]
                                                     fontName:@"Impact"
                                                     fontSize:30];
        labelPause2.anchorPoint = ccp(0.5, 1);
        labelPause2.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:labelPause2];

        self.isKeyboardEnabled = YES;
	}
	return self;
}

- (void)goToNextLevel
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MissionNotes sceneWithLevel:level+1]]];
}

- (BOOL)ccKeyDown:(NSEvent*)event
{
	//NSString* character = [event characters];
    //unichar keyCode = [character characterAtIndex:0];
    
    if (goingToNextScreen) {
        return NO;
    }
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"key.wav"];

    goingToNextScreen = YES;
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[Menu scene]]];
    //if (keyCode == 27) {
    //    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[Menu scene]]];
    //} else {
    //    [self goToNextLevel];
    //}

    return NO;
}

@end
