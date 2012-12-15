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
    tileSprites[i][j].anchorPoint = ccp(0.5, 0.5);
    tileSprites[i][j].position = ccp(TilesStartX + j*TileWidth + TileWidth/2, TilesStartY + i*TileHeight + TileHeight/2);
    [board addChild:tileSprites[i][j]];
}

- (CGPoint)centerOfTileY:(int)i X:(int)j
{
    return CGPointMake(TilesStartX + j*TileWidth + TileWidth/2, TilesStartY + i*TileHeight + TileHeight/2);
}

- (Tile*)tileContainingPosition:(CGPoint)point
{
    //NSLog(@"Clicked at %@", NSStringFromPoint(clickedAt));
    if (point.x >= TilesStartX && point.x <= TilesEndX
        && point.y >= TilesStartY && point.y <= TilesEndY) {
        int tileX = (point.x - TilesStartX) / TileWidth;
        int tileY = (point.y - TilesStartY) / TileHeight;
        //NSLog(@"Tile (y=%d, x=%d)", tileY, tileX);
        return &state.tiles[tileY][tileX];
    }
    return 0;
}

- (void)loadLevel:(int)level
{
    // Set tiles
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

    // Set character
    state.player.tileX = 1;
    state.player.tileY = TilesCountY-2;
    state.player.position = [self centerOfTileY:state.player.tileY X:state.player.tileX];

    // Create sprites
    for (int i=0; i<TilesCountY; ++i) {
        for (int j=0; j<TilesCountY; ++j) {
            [self setSpriteY:i X:j type:state.tiles[i][j].type];
        }
    }
    
    [self addChild:board];
    
    [playerSprite removeFromParentAndCleanup:YES];
    [playerSprite release];
    playerSprite = [[CCSprite alloc] initWithFile:@"Player.png"];
    playerSprite.position = state.player.position;

    [self addChild:playerSprite];
}

- (id)init
{
    self = [super init];
	if (self) {
		screenSize = [[CCDirector sharedDirector] winSize];
        
        board = [CCNode node];
		//CCLabelTTF *label = [CCLabelTTF labelWithString:@"Game" fontName:@"Marker Felt" fontSize:32];
		//label.position = ccp(size.width/2, size.height/2);
		//[self addChild:label];
        
        [self loadLevel:0];
        
        [self schedule:@selector(update:)];

        self.isKeyboardEnabled = YES;
        self.isMouseEnabled = YES;
        
        [[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority:0];
	}
	return self;
}

- (CGPoint)getCorrectedPositionForPosition:(CGPoint)originalPos dx:(float)dx dy:(float)dy
{
    Tile* originalTile = [self tileContainingPosition:originalPos];
    assert(originalTile && originalTile->type == 0);
    CGPoint originalTilePos = [self centerOfTileY:originalTile->y X:originalTile->x];

    CGPoint newPos = originalPos;
    newPos.x += dx;
    newPos.y += dy;
    
    const float hw = TileWidth/2-1;
    const float hh = TileHeight/2-1;
    Tile* tileTopLeft = [self tileContainingPosition:CGPointMake(newPos.x-hw, newPos.y+hh)];
    Tile* tileTopRight = [self tileContainingPosition:CGPointMake(newPos.x+hw, newPos.y+hh)];
    Tile* tileBottomLeft = [self tileContainingPosition:CGPointMake(newPos.x-hw, newPos.y-hh)];
    Tile* tileBottomRight = [self tileContainingPosition:CGPointMake(newPos.x+hw, newPos.y-hh)];
    bool topRightClear = tileTopRight && tileTopRight->type == 0;
    bool topLeftClear = tileTopLeft && tileTopLeft->type == 0;
    bool bottomRightClear = tileBottomRight && tileBottomRight->type == 0;
    bool bottomLeftClear = tileBottomLeft && tileBottomLeft->type == 0;
    if (dx > 0) {  // moving right
        if (!topRightClear || !bottomRightClear) {
            newPos.x = originalTilePos.x;
        }
    } else if (dx < 0) {  // moving left
        if (!topLeftClear || !bottomLeftClear) {
            newPos.x = originalTilePos.x;
        }
    }
    if (dy > 0) {  // moving up
        if (!topLeftClear || !topRightClear) {
            newPos.y = originalTilePos.y;
        }
    } else if (dy < 0) {  // moving down
        if (!bottomLeftClear || !bottomRightClear) {
            newPos.y = originalTilePos.y;
        }
    }

    return newPos;
}

- (void)update:(ccTime)dt
{
    Tile* playerTile = [self tileContainingPosition:state.player.position];

    /*static Tile* oldTile = playerTile;
    if (playerTile != oldTile) {
        if (playerTile)
            NSLog(@"Player in tile (%d, %d)", playerTile->y, playerTile->x);
        else
            NSLog(@"ERROR: No tile");
    }
    oldTile = playerTile;*/
    
    if (playerTile) {
        state.player.tileX = playerTile->x;
        state.player.tileY = playerTile->y;
    } else {
        assert(0);
    }

    if (movingDown) {
        state.player.position = [self getCorrectedPositionForPosition:state.player.position dx:0 dy:dt*PlayerSpeed];
        state.player.rotation = 270;
    }
    if (movingUp) {
        state.player.position = [self getCorrectedPositionForPosition:state.player.position dx:0 dy:-dt*PlayerSpeed];
        state.player.rotation = 90;
    }
    if (movingRight) {
        state.player.position = [self getCorrectedPositionForPosition:state.player.position dx:dt*PlayerSpeed dy:0];
        state.player.rotation = 0;
    }
    if (movingLeft) {
        state.player.position = [self getCorrectedPositionForPosition:state.player.position dx:-dt*PlayerSpeed dy:0];
        state.player.rotation = 180;
    }

    playerSprite.position = state.player.position;
    playerSprite.rotation = state.player.rotation;
}

- (void)clickedOnTileY:(int)tileY X:(int)tileX
{
    NSLog(@"clicked on tile %d, %d", tileY, tileX);
    state.tiles[tileY][tileX].type = (state.tiles[tileY][tileX].type + 1) % TileTypesCount;
    [self setSpriteY:tileY X:tileX type:state.tiles[tileY][tileX].type];
}

- (int)mouseEdit:(NSEvent*)event
{
    CGPoint clickedAt = [(CCDirectorMac*)[CCDirector sharedDirector] convertEventToGL:event];
    
    Tile* tile = [self tileContainingPosition:clickedAt];
    if (tile) {
        [self clickedOnTileY:tile->y X:tile->x];
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
	NSString* character = [event characters];
    unichar keyCode = [character characterAtIndex:0];
    
	// Player movement
	if (keyCode == 115) {
		movingUp = true;
	} else if (keyCode == 119) {
		movingDown = true;
	}
	if (keyCode == 97) {
		movingLeft = true;
	} else if (keyCode == 100) {
		movingRight = true;
	}
    return YES;
}

- (BOOL)ccKeyUp:(NSEvent*)event
{
	NSString* character = [event characters];
    unichar keyCode = [character characterAtIndex:0];
    
	// Player movement
	if (keyCode == 115) {
		movingUp = false;
	} else if (keyCode == 119) {
		movingDown = false;
	}
	if (keyCode == 97) {
		movingLeft = false;
	} else if (keyCode == 100) {
		movingRight = false;
	}
    return YES;
}


@end
