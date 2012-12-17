//
//  Menu.m
//  LudumDare25
//
//  Created by Manuel Freire on 15/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Menu.h"

#import "GameScene.h"
#import "GameProgress.h"
#import "MissionNotes.h"
#import "SimpleAudioEngine.h"

@implementation Menu

+ (CCScene*)scene
{
	CCScene* scene = [CCScene node];
	
	Menu* layer = [Menu node];
	
	[scene addChild:layer];
	
	return scene;
}

- (id)init
{
    self = [super init];
	if (self) {
        progress = loadProgress();
        
        ccColor3B colorDisabled = ccc3(100, 100, 100);
        ccColor3B colorEnabled = ccc3(255, 255, 255);
        
        CCMenuItemLabel* level1 = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"1. STEALTH" fontName:@"Impact" fontSize:32]
                                                          target:self
                                                        selector:@selector(goToLevel1)];
        level1.color = progress.levelAvailable[0] ? colorEnabled : colorDisabled;
        
        CCMenuItemLabel* level2 = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"2. LIGHTS" fontName:@"Impact" fontSize:32]
                                                          target:self
                                                        selector:@selector(goToLevel2)];
        level2.color = progress.levelAvailable[1] ? colorEnabled : colorDisabled;
        
        CCMenuItemLabel* level3 = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"3. DOORS" fontName:@"Impact" fontSize:32]
                                                          target:self
                                                        selector:@selector(goToLevel3)];
        level3.color = progress.levelAvailable[2] ? colorEnabled : colorDisabled;
        
        CCMenuItemLabel* level4 = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"4. KILL" fontName:@"Impact" fontSize:32]
                                                          target:self
                                                        selector:@selector(goToLevel4)];
        level4.color = progress.levelAvailable[3] ? colorEnabled : colorDisabled;
        
        CCMenuItemLabel* level5 = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"5. BARBADOS" fontName:@"Impact" fontSize:32]
                                                          target:self
                                                        selector:@selector(goToLevel5)];
        level5.color = progress.levelAvailable[4] ? colorEnabled : colorDisabled;
        
        CCMenu* menu = [CCMenu menuWithItems:level1, level2, level3, level4, level5, nil];
        [menu alignItemsHorizontallyWithPadding:100];
        [self addChild:menu];
        
        self.isKeyboardEnabled = YES;
	}
	return self;
}

- (void)goToLevel:(int)level
{
    if (!goingToGame && progress.levelAvailable[level-1]) {
        goingToGame = true;
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MissionNotes sceneWithLevel:level]]];
    }
}

- (void)goToLevel1
{
    [self goToLevel:1];
}

- (void)goToLevel2
{
    [self goToLevel:2];
}

- (void)goToLevel3
{
    [self goToLevel:3];
}

- (void)goToLevel4
{
    [self goToLevel:4];
}

- (void)goToLevel5
{
    [self goToLevel:5];
}

- (BOOL)ccKeyUp:(NSEvent *)event
{
    //[[SimpleAudioEngine sharedEngine] playEffect:@"key.wav"];
    return NO;
}

- (BOOL)ccKeyDown:(NSEvent*)event
{
	NSString* character = [event characters];
    unichar keyCode = [character characterAtIndex:0];

    if (keyCode >= 49 && keyCode <= 53) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"key.wav"];
        int level = keyCode-48;
        [self goToLevel:level];
    }
    
    if (keyCode == 27) {
        [NSApp terminate:self];
    }
    
    return NO;
}

@end
