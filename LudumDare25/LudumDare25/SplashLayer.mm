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
        
        CCLabelTTF* label = [CCLabelTTF labelWithString:@"THE VAULT" fontName:@"Monaco" fontSize:40];
        CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"A 48-hour Ludum Dare game by Manuel Freire" fontName:@"Monaco" fontSize:24];
        label.position = ccp(size.width/2, size.height/2);
        label2.position = ccp(size.width/2, size.height/2-50);
        [self addChild:label];
        [self addChild:label2];
        
        self.isKeyboardEnabled = YES;
        
        //[self performSelector:@selector(goToNextScreen) withObject:nil afterDelay:3];
	}
	return self;
}

- (void)goToNextScreen
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:2.0 scene:[Menu scene]]];
}

- (BOOL)ccKeyDown:(NSEvent*)event
{
    if (!keyPressed) {
        [self goToNextScreen];
    }
    return YES;
}


@end
