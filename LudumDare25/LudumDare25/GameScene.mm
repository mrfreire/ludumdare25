//
//  GameScene.m
//  LudumDare25
//
//  Created by Manuel Freire on 15/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

+ (CCScene*)sceneWithLevel:(int)level
{
	CCScene* scene = [CCScene node];
	
	GameScene* layer = [[[GameScene alloc] initWithLevel:level] autorelease];
	
	[scene addChild:layer];
	
	return scene;
}

- (void)dealloc
{
    [super dealloc];
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

- (void)loadLevel
{
    FILE* f = fopen(((NSString*)[NSString stringWithFormat:@"level%d.bin", level]).UTF8String, "r");
    if (f) {
        fread(&state, sizeof(state), 1, f);
        fclose(f);
    } else {  // level doesn't exist
        // Set tiles
        for (int i=0; i<TilesCountY; ++i) {
            for (int j=0; j<TilesCountY; ++j) {
                Tile tile = Tile();
                tile.type = Floor;
                tile.x = j;
                tile.y = i;
                tile.isExit = false;
                state.tiles[i][j] = tile;
            }
        }
    }
    
    // Reset character
    state.player.rotation = 0;
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

- (id)initWithLevel:(int)level_
{
    self = [super init];
	if (self) {
        level = level_;
        
		screenSize = [[CCDirector sharedDirector] winSize];
        
        board = [CCNode node];
		
        CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"LEVEL %d", level] fontName:@"Monaco" fontSize:20];
        label.anchorPoint = ccp(0, 0);
		label.position = ccp(20, 20);
		[self addChild:label];
        
        [self loadLevel];
        
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
    assert(originalTile && TileIsWalkable[originalTile->type]);
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
    bool topRightClear = tileTopRight && TileIsWalkable[tileTopRight->type];
    bool topLeftClear = tileTopLeft && TileIsWalkable[tileTopLeft->type];
    bool bottomRightClear = tileBottomRight && TileIsWalkable[tileBottomRight->type];
    bool bottomLeftClear = tileBottomLeft && TileIsWalkable[tileBottomLeft->type];
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
    if (finished) {
        [self unscheduleAllSelectors];
        [[CCEventDispatcher sharedDispatcher] removeAllMouseDelegates];
    }
    
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
    state.tiles[tileY][tileX].type = editorSelectedTile;
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
    
    // Editor
    if (keyCode >= 48 && keyCode <= 57) {
        int type = keyCode-48;
        if (type < TileTypesCount) {
            editorSelectedTile = type;
        }
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
    
    // Editor
    if (keyCode == 112) {  // p
        NSLog(@"Saving level data");
        FILE* f = fopen(((NSString*)[NSString stringWithFormat:@"level%d.bin", level]).UTF8String, "w");
        if (f) {
            fwrite(&state, sizeof(state), 1, f);
            fclose(f);
        } else {
            assert(0);
        }

        f = fopen(((NSString*)[NSString stringWithFormat:@"/Users/manuel/level%d.bin", level]).UTF8String, "w");
        if (f) {
            fwrite(&state, sizeof(state), 1, f);
            fclose(f);
        } else {
            assert(0);
        }
    }
    if (keyCode == 44) {  // ,
        if (level > 0) {
            finished = true;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameScene sceneWithLevel:level-1]]];
        }
    }
    if (keyCode == 46) {  // .
        finished = true;
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameScene sceneWithLevel:level+1]]];
    }
    
    return YES;
}


@end
