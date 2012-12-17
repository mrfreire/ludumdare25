//
//  SplashLayer.mm
//  LudumDare25
//
//  Created by Manuel Freire on 15/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "SplashLayer.h"
#import "Menu.h"

@implementation SplashLayer

+ (CCScene*)sceneWithId:(int)i
{
	CCScene *scene = [CCScene node];
	SplashLayer *layer = [[[SplashLayer alloc] initWithId:i] autorelease];
	[scene addChild:layer];
	return scene;
}

-(id)initWithId:(int)i
{
	if( (self=[super init]) ) {
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF* label = [CCLabelTTF labelWithString:@"THE VAULT" fontName:@"Impact" fontSize:120];
        CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"A 48-hour Ludum Dare game by Manuel Freire" fontName:@"Impact" fontSize:24];
        label.anchorPoint = ccp(0.5, 0.5);
        label.position = ccp(size.width/2, size.height*2/3);
        label2.anchorPoint = ccp(0.5, 1);
        label2.position = ccp(size.width/2, size.height*1/3);
        [self addChild:label];
        [self addChild:label2];
        
        self.isKeyboardEnabled = YES;
        [self performSelector:@selector(goToNextScreen) withObject:nil afterDelay:3];
	}
	return self;
}

- (void)goToNextScreen
{
    if (!goingToNextScreen) {
        goingToNextScreen = YES;
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[Menu scene]]];
    }
}

- (BOOL)ccKeyDown:(NSEvent*)event
{
    [self goToNextScreen];
    return NO;
}


@end
