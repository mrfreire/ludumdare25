//
//  AppDelegate.m
//  LudumDare25
//
//  Created by Manuel Freire on 15/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "AppDelegate.h"

#import "SplashLayer.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"

@implementation LudumDare25AppDelegate
@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];

	// enable FPS and SPF
	//[director setDisplayStats:YES];
	
	// connect the OpenGL view with the director
	[director setView:glView_];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_AutoScale];
	
    CGDisplayHideCursor(kCGDirectMainDisplay);
    
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// Center main window
	[window_ center];
	
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"cash.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"door.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"key.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"knife.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"light.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"lose.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"vaultdoor.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"win.wav"];
    
    //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bg.aif"];
    
	//[director runWithScene:[GameScene sceneWithLevel:0]];
    [director runWithScene:[CCTransitionFade transitionWithDuration:1.0 scene:[SplashLayer sceneWithId:0]]];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication
{
	return YES;
}

- (void)dealloc
{
	[[CCDirector sharedDirector] end];
	[window_ release];
	[super dealloc];
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen:(id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ![director isFullScreen]];
}

@end
