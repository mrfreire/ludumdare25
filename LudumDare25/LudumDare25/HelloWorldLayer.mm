//
//  HelloWorldLayer.m
//  LudumDare25
//
//  Created by Manuel Freire on 15/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "Menu.h"

@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init]) ) {
		
		CGSize size = [[CCDirector sharedDirector] winSize];

        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Splash" fontName:@"Marker Felt" fontSize:32];
		label.position =  ccp( size.width /2 , size.height/2 );
		[self addChild: label];
        
        keyPressed = NO;
        
        self.isKeyboardEnabled = YES;
        
        [self performSelector:@selector(goToNextScreen) withObject:nil afterDelay:2.0f];
	}
	return self;
}

- (void)goToNextScreen
{
    if (!keyPressed) {
        keyPressed = YES;
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[Menu scene]]];
    }
}

- (BOOL)ccKeyUp:(NSEvent*)event
{
    if (!keyPressed) {
        [self goToNextScreen];
    }
    return YES;
}


@end
