//
//  GameScene.m
//  LudumDare25
//
//  Created by Manuel Freire on 15/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

+ (CCScene*)scene
{
	CCScene* scene = [CCScene node];
	
	GameScene* layer = [GameScene node];
	
	[scene addChild:layer];
	
	return scene;
}

- (void)loadLevel:(int)level
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // Create sprites
    for (int i=0; i<TilesCountY; ++i) {
        for (int j=0; j<TilesCountY; ++j) {
            Tile tile = Tile();
            tile.type = 0;
            tile.x = j;
            tile.y = i;
            tile.isExit = false;
            state.tiles[i][j] = tile;
        }
    }

    // Create sprites
    for (int i=0; i<TilesCountY; ++i) {
        for (int j=0; j<TilesCountY; ++j) {
            if (tileSprites[i][j]) {
                [tileSprites[i][j] removeFromParentAndCleanup:YES];
                [tileSprites[i][j] release];
            }
            tileSprites[i][j] = [[CCSprite alloc] initWithFile:[NSString stringWithFormat:@"Tile%d.png", state.tiles[i][j].type]];
            tileSprites[i][j].anchorPoint = ccp(0, 1);
            tileSprites[i][j].position = ccp(TilesStartX + j*TileWidth, size.height - TilesStartY - i*TileHeight);
            [self addChild:tileSprites[i][j]];
        }
    }
}

- (id)init
{
    self = [super init];
	if (self) {
		//CGSize size = [[CCDirector sharedDirector] winSize];
        
		//CCLabelTTF *label = [CCLabelTTF labelWithString:@"Game" fontName:@"Marker Felt" fontSize:32];
		//label.position = ccp(size.width/2, size.height/2);
		//[self addChild:label];
        
        [self loadLevel:0];
        
        [self schedule:@selector(update:) interval:1];
	}
	return self;
}

- (void)update:(ccTime)dt
{
    
}

@end
