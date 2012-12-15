//
//  Menu.m
//  LudumDare25
//
//  Created by Manuel Freire on 15/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Menu.h"
#import "GameScene.h"

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
		CGSize size = [[CCDirector sharedDirector] winSize];

		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Menu" fontName:@"Marker Felt" fontSize:32];
        label.position = ccp(size.width/2, size.height/2);
		[self addChild:label];

        CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"Press any key to start" fontName:@"Marker Felt" fontSize:32];
        label2.anchorPoint = ccp(0.5, 0);
        label2.position = ccp(size.width/2, 10);
        [self addChild:label2];
        
        self.isKeyboardEnabled = YES;

        /*CCMenuItemLabel* start = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Start game" fontName:@"Copperplate" fontSize:24.0]
                                                         target:self
                                                       selector:@selector(startGame)];
        CCMenu* menu = [CCMenu menuWithItems:start, nil];
        [self addChild:menu];*/
	}
	return self;
}

-(BOOL)ccKeyUp:(NSEvent*)event
{
    [self startGame];
    return YES;
}

- (void)startGame
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameScene scene]]];
}

@end
