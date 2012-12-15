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

- (void)setSpriteY:(int)i X:(int)j type:(int)type
{
    if (tileSprites[i][j]) {
        [tileSprites[i][j] removeFromParentAndCleanup:YES];
        [tileSprites[i][j] release];
    }
    tileSprites[i][j] = [[CCSprite alloc] initWithFile:[NSString stringWithFormat:@"Tile%d.png", type]];
    tileSprites[i][j].anchorPoint = ccp(0, 1);
    tileSprites[i][j].position = ccp(TilesStartX + j*TileWidth, screenSize.height - TilesStartY - i*TileHeight);
    [self addChild:tileSprites[i][j]];
}

- (void)loadLevel:(int)level
{
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
            [self setSpriteY:i X:j type:state.tiles[i][j].type];
        }
    }
}

- (id)init
{
    self = [super init];
	if (self) {
		screenSize = [[CCDirector sharedDirector] winSize];
        
		//CCLabelTTF *label = [CCLabelTTF labelWithString:@"Game" fontName:@"Marker Felt" fontSize:32];
		//label.position = ccp(size.width/2, size.height/2);
		//[self addChild:label];
        
        [self loadLevel:0];
        
        [self schedule:@selector(update:) interval:1];

        self.isKeyboardEnabled = YES;
        self.isMouseEnabled = YES;
        
        [[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority:0];
	}
	return self;
}

- (void)update:(ccTime)dt
{
    
}

- (void)clickedOnTileY:(int)tileY X:(int)tileX
{
    state.tiles[tileY][tileX].type = (state.tiles[tileY][tileX].type + 1) % TileTypesCount;
    [self setSpriteY:tileY X:tileX type:state.tiles[tileY][tileX].type];
}

- (int)mouseEdit:(NSEvent*)event
{
    CGPoint clickedAt = [(CCDirectorMac*)[CCDirector sharedDirector] convertEventToGL:event];
    clickedAt.y = (screenSize.height - clickedAt.y);
    
    //NSLog(@"Clicked at %@", NSStringFromPoint(clickedAt));
    if (clickedAt.x >= TilesStartX && clickedAt.x <= TilesEndX
        && clickedAt.y >= TilesStartY && clickedAt.y <= TilesEndY) {
        int tileX = (clickedAt.x - TilesStartX) / TileWidth;
        int tileY = (clickedAt.y - TilesStartY) / TileHeight;
        //NSLog(@"Tile (y=%d, x=%d)", tileY, tileX);
        [self clickedOnTileY:tileY X:tileX];
    } else {
        //NSLog(@"Invalid tile");
    }
    
	return YES;
}

- (BOOL)ccMouseDragged:(NSEvent*)event
{
    return [self mouseEdit:event];
    //return YES;
}

- (BOOL)ccMouseDown:(NSEvent*)event
{
    return [self mouseEdit:event];
}

- (BOOL)ccKeyDown:(NSEvent*)event
{
    return YES;
}


@end
