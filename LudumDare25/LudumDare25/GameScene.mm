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

- (void)setItemSprite:(int)i Y:(int)y X:(int)x type:(int)type
{
    if (itemSprites[i]) {
        [itemSprites[i] removeFromParentAndCleanup:YES];
        [itemSprites[i] release];
    }
    itemSprites[i] = [[CCSprite alloc] initWithFile:[NSString stringWithFormat:@"Item%d.png", type]];
    itemSprites[i].anchorPoint = ccp(0.5, 0.5);
    itemSprites[i].position = [self centerOfTileY:y X:x];
    [board addChild:itemSprites[i]];
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
    
    // Reset characters & items
    state.player.rotation = 0;
    state.player.position = [self centerOfTileY:state.player.tileY X:state.player.tileX];
    for (int i=0; i<MaxEnemyCount; ++i) {
        Enemy& enemy = state.enemies[i];
        enemy.position = [self centerOfTileY:enemy.patrolTileA[0] X:enemy.patrolTileA[1]];
        enemy.state = 0;
        enemy.substate = 2;
    }
    for (int i=0; i<MaxItemCount; ++i) {
        Item& item = state.items[i];
        item.collected = false;
    }

    // Create sprites
    for (int i=0; i<TilesCountY; ++i) {
        for (int j=0; j<TilesCountX; ++j) {
            [self setSpriteY:i X:j type:state.tiles[i][j].type];
        }
    }
 
    for (int i=0; i<MaxItemCount; ++i) {
        const Item& item = state.items[i];
        [self setItemSprite:i Y:item.tileY X:item.tileX type:item.type];
        itemSprites[i].visible = NO;
    }
    

    [self addChild:board];
    
    [playerSprite removeFromParentAndCleanup:YES];
    [playerSprite release];
    playerSprite = [[CCSprite alloc] initWithFile:@"Player.png"];
    playerSprite.position = state.player.position;
    [self addChild:playerSprite];

    for (int i=0; i<MaxEnemyCount; ++i) {
        enemySprites[i] = [[CCSprite alloc] initWithFile:@"Enemy.png"];
        enemySprites[i].position = state.enemies[i].position;
        enemySprites[i].visible = state.enemies[i].active;
        [self addChild:enemySprites[i]];
    }
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
        
        deactivatingLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 160) width:screenSize.width height:screenSize.height];
        deactivatingLayer.position = ccp(0, 0);
        deactivatingLayer.visible = NO;
        CCLabelTTF* openingLabel = [CCLabelTTF labelWithString:@"YOU ARE OPENING THE VAULT." fontName:@"Monaco" fontSize:20];
        openingLabel.position = ccp(screenSize.width/2, screenSize.height/2+20);
        [deactivatingLayer addChild:openingLabel];
        deactivationCountdownLabel = [CCLabelTTF labelWithString:@"OPENING TIME: " fontName:@"Monaco" fontSize:20];
        deactivationCountdownLabel.position = ccp(screenSize.width/2, screenSize.height/2-20);
        [deactivatingLayer addChild:deactivationCountdownLabel];
        
        [self addChild:deactivatingLayer];
        
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
    assert(originalTile);
    /*if (!TileIsWalkable[originalTile->type]) {
        return originalPos;
    }*/
    
    CGPoint originalTilePos = [self centerOfTileY:originalTile->y X:originalTile->x];

    CGPoint newPos = originalPos;
    newPos.x += dx;
    newPos.y += dy;
    
    const float hw = TileWidth/2-2;
    const float hh = TileHeight/2-2;
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

- (void)restartLevel
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameScene sceneWithLevel:level]]];
}

- (void)advanceLevel
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameScene sceneWithLevel:level+1]]];
}

- (void)lose
{
    finished = true;
    lost = true;
    
    deactivatingLayer.visible = NO;

    CCLayerColor* overlay = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 160)];
    [self addChild:overlay];
    CCLabelTTF* label = [CCLabelTTF labelWithString:@"YOU HAVE BEEN DISCOVERED!" fontName:@"Monaco" fontSize:30];
    label.position = ccp(screenSize.width/2, screenSize.height/2);
    [self addChild:label];
    
    [self performSelector:@selector(restartLevel) withObject:nil afterDelay:2.0f];
}

- (void)win
{
    finished = true;
    lost = true;
    
    deactivatingLayer.visible = NO;
    
    CCLayerColor* overlay = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 160)];
    [self addChild:overlay];
    CCLabelTTF* label = [CCLabelTTF labelWithString:@"YOU MADE IT!" fontName:@"Monaco" fontSize:30];
    label.position = ccp(screenSize.width/2, screenSize.height/2);
    [self addChild:label];
    
    [self performSelector:@selector(advanceLevel) withObject:nil afterDelay:2.0f];
}

- (void)updateLighting
{
    for (int i=0; i<TilesCountY; ++i) {
        for (int j=0; j<TilesCountX; ++j) {
            state.tiles[i][j].light = AmbientLight;
        }
    }
    
    for (int i=0; i<MaxEnemyCount; ++i) {
        const Enemy& enemy = state.enemies[i];
        if (enemy.active) {  // cast light
            float direction = enemy.rotation;
            int tileX = enemy.tileX;
            int tileY = enemy.tileY;
            CGPoint tilePosition = [self centerOfTileY:tileY X:tileX];
            float offsetFromTileCenterX = (enemy.position.x - (tilePosition.x - TileWidth/2)) / TileWidth;
            float offsetFromTileCenterY = (enemy.position.y - (tilePosition.y - TileWidth/2)) / TileWidth;
            float lightOffset;
            if (direction == East) {
                lightOffset = offsetFromTileCenterX;
            } else if (direction == West) {
                lightOffset = 1-offsetFromTileCenterX;
            } else if (direction == North) {
                lightOffset = offsetFromTileCenterY;
            } else {
                lightOffset = 1-offsetFromTileCenterY;
            }
            for (int light = 14; light>0; --light) {
                if (light == 14)
                    state.tiles[tileY][tileX].light += light*LightQuant*(1-lightOffset);
                else
                    state.tiles[tileY][tileX].light += light*LightQuant+lightOffset*LightQuant;
                if (direction == East) {
                    ++tileX;
                    if (tileX >= TilesCountX || !TileIsWalkable[state.tiles[tileY][tileX].type]) {  // wall
                        light -= LightAbsorption;
                        direction = West;
                        --tileX;
                    }
                } else if (direction == West) {
                    --tileX;
                    if (tileX < 0 || !TileIsWalkable[state.tiles[tileY][tileX].type]) {  // wall
                        light -= LightAbsorption;
                        direction = East;
                        ++tileX;
                    }
                } else if (direction == North) {
                    ++tileY;
                    if (tileY >= TilesCountY || !TileIsWalkable[state.tiles[tileY][tileX].type]) {  // wall
                        light -= LightAbsorption;
                        direction = South;
                        --tileY;
                    }
                } else {
                    --tileY;
                    if (tileY < 0 || !TileIsWalkable[state.tiles[tileY][tileX].type]) {  // wall
                        light -= LightAbsorption;
                        direction = North;
                        ++tileY;
                    }
                }
            }
        }
    }
    
    for (int i=0; i<TilesCountY; ++i) {
        for (int j=0; j<TilesCountX; ++j) {
            int light = min(state.tiles[i][j].light, 255);
            if (light == AmbientLight) {
                tileSprites[i][j].color = ccc3(light*0.8, light*0.8, light);
            } else {
                tileSprites[i][j].color = ccc3(light, light, light);
            }
        }
    }
}

- (void)update:(ccTime)dt
{
    if (finished) {
        [self unscheduleAllSelectors];
        [[CCEventDispatcher sharedDispatcher] removeAllMouseDelegates];
        return;
    }

    Player& player = state.player;
    
    // Move player
    if (!deactivating) {
        if (movingDown) {
            player.position = [self getCorrectedPositionForPosition:player.position dx:0 dy:-dt*PlayerSpeed];
            player.rotation = 90;
        }
        if (movingUp) {
            player.position = [self getCorrectedPositionForPosition:player.position dx:0 dy:dt*PlayerSpeed];
            player.rotation = 270;
        }
        if (movingRight) {
            player.position = [self getCorrectedPositionForPosition:player.position dx:dt*PlayerSpeed dy:0];
            player.rotation = 0;
        }
        if (movingLeft) {
            player.position = [self getCorrectedPositionForPosition:player.position dx:-dt*PlayerSpeed dy:0];
            player.rotation = 180;
        }
    }
    
    // Move enemy (editor)
    Enemy& selectedEnemy = state.enemies[editorSelectedEnemy];
    if (selectedEnemy.active) {
        if (editorMovingDown) {
            selectedEnemy.position = [self getCorrectedPositionForPosition:selectedEnemy.position dx:0 dy:-dt*EnemyRunSpeed];
            selectedEnemy.rotation = 90;
        }
        if (editorMovingUp) {
            selectedEnemy.position = [self getCorrectedPositionForPosition:selectedEnemy.position dx:0 dy:dt*EnemyRunSpeed];
            selectedEnemy.rotation = 270;
        }
        if (editorMovingRight) {
            selectedEnemy.position = [self getCorrectedPositionForPosition:selectedEnemy.position dx:dt*EnemyRunSpeed dy:0];
            selectedEnemy.rotation = 0;
        }
        if (editorMovingLeft) {
            selectedEnemy.position = [self getCorrectedPositionForPosition:selectedEnemy.position dx:-dt*EnemyRunSpeed dy:0];
            selectedEnemy.rotation = 180;
        }
    }
    
    // Update AI
    for (int i=0; i<MaxEnemyCount; ++i) {
        Enemy& enemy = state.enemies[i];
        if (!enemy.active) {
            continue;
        }
        if (enemy.state == 0) {  // patrolling
            if (enemy.substate == 0 || enemy.substate == 2) {  // walking
                int* patrolTile = enemy.substate == 0 ? enemy.patrolTileB : enemy.patrolTileA;
                CGPoint dest = [self centerOfTileY:patrolTile[0] X:patrolTile[1]];
                if (enemy.position.y < dest.y) {
                    enemy.position = [self getCorrectedPositionForPosition:enemy.position dx:0 dy:EnemyWalkSpeed*dt];
                    if (enemy.position.y > dest.y) {
                        enemy.position.y = dest.y;
                    }
                    enemy.rotation = 270;
                } else if (enemy.position.y > dest.y) {
                    enemy.position = [self getCorrectedPositionForPosition:enemy.position dx:0 dy:-EnemyWalkSpeed*dt];
                    if (enemy.position.y < dest.y) {
                        enemy.position.y = dest.y;
                    }
                    enemy.rotation = 90;
                }
                if (enemy.position.x < dest.x) {
                    enemy.position = [self getCorrectedPositionForPosition:enemy.position dx:EnemyWalkSpeed*dt dy:0];
                    if (enemy.position.x > dest.x) {
                        enemy.position.x = dest.x;
                    }
                    enemy.rotation = 0;
                } else if (enemy.position.x > dest.x) {
                    enemy.position = [self getCorrectedPositionForPosition:enemy.position dx:-EnemyWalkSpeed*dt dy:0];
                    if (enemy.position.x < dest.x) {
                        enemy.position.x = dest.x;
                    }
                    enemy.rotation = 180;
                }
                
                if (enemy.position.x == dest.x && enemy.position.y == dest.y) {
                    enemy.substate = enemy.substate == 0 ? 1 : 3;
                    enemy.stateParams[0] = CFAbsoluteTimeGetCurrent();
                }
            } else if (enemy.substate == 1 || enemy.substate == 3) {  // waiting
                int phase = (CFAbsoluteTimeGetCurrent() - enemy.stateParams[0]) / EnemyWaitDuration * 4;
                if (phase >= 4) {
                    enemy.substate = enemy.substate == 1 ? 2 : 0;
                } else {
                    assert(phase >= 0);
                    int* patrolRotation = enemy.substate == 1 ? enemy.patrolRotationB : enemy.patrolRotationA;
                    enemy.rotation = patrolRotation[phase];
                }
            }
        }
    }
    
    // Update tile where each character is
    Tile* playerTile = [self tileContainingPosition:player.position];
    assert(playerTile);
    player.tileX = playerTile->x;
    player.tileY = playerTile->y;
    for (int i=0; i<MaxEnemyCount; ++i) {
        Tile* enemyTile = [self tileContainingPosition:state.enemies[i].position];
        assert(enemyTile);
        state.enemies[i].tileX = enemyTile->x;
        state.enemies[i].tileY = enemyTile->y;
    }

    // Check detection
    for (int i=0; i<MaxEnemyCount; ++i) {
        Enemy& enemy = state.enemies[i];
        bool detected = false;
        float diffX = fabsf(enemy.position.x - player.position.x);
        float diffY = fabsf(enemy.position.y - player.position.y);
        if (diffX < TileWidth/(1+DetectionThreshold)) {
            if (enemy.rotation == 270) {  // facing up
                for (int y=enemy.tileY; y<TilesCountY; ++y) {
                    if (!TileIsWalkable[state.tiles[y][enemy.tileX].type]) {
                        break;
                    }
                    if (player.tileY == y) {
                        detected = true;
                        break;
                    }
                }
            } else if (enemy.rotation == 90) {  // facing down
                for (int y=enemy.tileY; y>=0; --y) {
                    if (!TileIsWalkable[state.tiles[y][enemy.tileX].type]) {
                        break;
                    }
                    if (player.tileY == y) {
                        detected = true;
                        break;
                    }
                }
            }
        }
        if (diffY < TileHeight/(1+DetectionThreshold)) {
            if (enemy.rotation == 180) {  // facing left
                for (int x=enemy.tileX; x>=0; --x) {
                    if (!TileIsWalkable[state.tiles[enemy.tileY][x].type]) {
                        break;
                    }
                    if (player.tileX == x) {
                        detected = true;
                        break;
                    }
                }
            } else if (enemy.rotation == 0) {  // facing right
                for (int x=enemy.tileX; x<TilesCountX; ++x) {
                    if (!TileIsWalkable[state.tiles[enemy.tileY][x].type]) {
                        break;
                    }
                    if (player.tileX == x) {
                        detected = true;
                        break;
                    }
                }
            }
        }
        if (detected) {
            detectedBy = i;
            [self lose];
            break;
        }
    }
    
    if (deactivating) {  // update deactivation
        Tile& tile = state.tiles[tileBeingDeactivated[0]][tileBeingDeactivated[1]];
        float elapsed = CFAbsoluteTimeGetCurrent() - deactivateStartTime;
        if (elapsed >= DoorOpeningTime) {  // open!
            deactivating = false;
            tile.type = Vault;
            [self setSpriteY:tile.y X:tile.x type:tile.type];
            deactivatingLayer.visible = NO;
        } else {
            int secsToGo = ceilf(DoorOpeningTime - elapsed);
            [deactivationCountdownLabel setString:[NSString stringWithFormat:@"OPENING TIME: 00:%02d", secsToGo]];
            deactivatingLayer.visible = YES;
        }
    } else {
        deactivatingLayer.visible = NO;
    }
    
    if (deactivatePressed && !deactivating) {  // start deactivating
        if (player.tileX < TilesCountX-1) {  // check right
            if (state.tiles[player.tileY][player.tileX+1].type == Door) {
                tileBeingDeactivated[0] = player.tileY;
                tileBeingDeactivated[1] = player.tileX+1;
                deactivating = true;
            }
        }
        if (player.tileX > 0) {  // check left
            if (state.tiles[player.tileY][player.tileX-1].type == Door) {
                tileBeingDeactivated[0] = player.tileY;
                tileBeingDeactivated[1] = player.tileX-1;
                deactivating = true;
            }
        }
        if (player.tileY < TilesCountY-1) {  // check up
            if (state.tiles[player.tileY+1][player.tileX].type == Door) {
                tileBeingDeactivated[0] = player.tileY+1;
                tileBeingDeactivated[1] = player.tileX;
                deactivating = true;
            }
        }
        if (player.tileY > 0) {  // check down
            if (state.tiles[player.tileY-1][player.tileX].type == Door) {
                tileBeingDeactivated[0] = player.tileY-1;
                tileBeingDeactivated[1] = player.tileX;
                deactivating = true;
            }
        }

        if (deactivating) {
            deactivateStartTime = CFAbsoluteTimeGetCurrent();
        }
    }
    
    // Check item collection
    for (int i=0; i<MaxItemCount; ++i) {
        Item& item = state.items[i];
        if (item.active && !item.collected) {
            if (item.tileX == player.tileX && item.tileY == player.tileY) {  // collect item
                item.collected = true;
                itemSprites[i].position = ccp(20+(itemsInInventory%4)*ItemWidth+ItemWidth/2,
                                              screenSize.height-20-ItemHeight/2-(itemsInInventory/4)*ItemHeight);
                ++itemsInInventory;
            }
        }
    }

    // Check win
    if (playerTile->type == Exit) {
        bool allCollected = true;
        for (int i=0; i<MaxItemCount; ++i) {
            const Item& item = state.items[i];
            if (item.mustBeCollected && !item.collected) {
                allCollected = false;
            }
        }
        if (allCollected) {
            [self win];
        }
    }
    
    // Update lighting
    [self updateLighting];
    
    // Update sprites
    playerSprite.position = player.position;
    playerSprite.rotation = player.rotation;
    for (int i=0; i<MaxEnemyCount; ++i) {
        const Enemy& enemy = state.enemies[i];
        enemySprites[i].visible = enemy.active;
        enemySprites[i].position = enemy.position;
        enemySprites[i].rotation = enemy.rotation;
    }
    for (int i=0; i<MaxItemCount; ++i) {
        const Item& item = state.items[i];
        itemSprites[i].visible = item.active;
    }
}

- (void)clickedOnTileY:(int)tileY X:(int)tileX
{
    NSLog(@"clicked on tile %d, %d", tileY, tileX);
    state.tiles[tileY][tileX].type = editorSelectedTile;
    [self setSpriteY:tileY X:tileX type:state.tiles[tileY][tileX].type];
}

- (void)clickedOnItemY:(int)tileY X:(int)tileX
{
    int i;
    for (i=0; i<MaxItemCount; ++i) {
        const Item& item = state.items[i];
        if (item.active && item.tileY == tileY && item.tileX == tileX) {
            break;
        }
    }
    
    if (i == MaxItemCount) {  // no item exists, create it
        for (i=0; i<MaxItemCount; ++i) {
            if (!state.items[i].active) {
                break;
            }
        }
        if (i < MaxItemCount) {
            state.items[i].active = true;
            state.items[i].collected = false;
            state.items[i].mustBeCollected = true;
            state.items[i].type = -1;
            state.items[i].tileY = tileY;
            state.items[i].tileX = tileX;
        }
    }
    
    if (i < MaxItemCount) {  // cycle through type
        ++state.items[i].type;
        if (state.items[i].type >= ItemTypesCount) {
            state.items[i].type = 0;
            state.items[i].active = false;
        } else {
            [self setItemSprite:i Y:tileY X:tileX type:state.items[i].type];
        }
    }
}

- (int)mouseEdit:(NSEvent*)event item:(BOOL)isItem
{
    CGPoint clickedAt = [(CCDirectorMac*)[CCDirector sharedDirector] convertEventToGL:event];
    
    Tile* tile = [self tileContainingPosition:clickedAt];
    if (tile) {
        if (isItem) {
            [self clickedOnItemY:tile->y X:tile->x];
        } else {
            [self clickedOnTileY:tile->y X:tile->x];
        }
    }
	return YES;
}

- (BOOL)ccMouseDragged:(NSEvent*)event
{
    return [self mouseEdit:event item:editorItemPickEnabled];
    //return YES;
}

- (BOOL)ccMouseDown:(NSEvent*)event
{
    return [self mouseEdit:event item:editorItemPickEnabled];
}

- (BOOL)ccKeyDown:(NSEvent*)event
{
	NSString* character = [event characters];
    unichar keyCode = [character characterAtIndex:0];
    
	// Player movement
	if (keyCode == 119) {
		movingUp = true;
	} else if (keyCode == 115) {
		movingDown = true;
	}
	if (keyCode == 97) {
		movingLeft = true;
	} else if (keyCode == 100) {
		movingRight = true;
	}
    
    // Player actions
    if (keyCode == 32) {  // space
        deactivatePressed = true;
    }
    
    // Editor
    if (keyCode >= 48 && keyCode <= 57) {
        int type = keyCode-48;
        if (type < TileTypesCount) {
            editorSelectedTile = type;
        }
    }
    if (keyCode == 63234) {  // left
        editorMovingLeft = true;
    }
    if (keyCode == 63235) {  // right
        editorMovingRight = true;
    }
    if (keyCode == 63232) {  // up
        editorMovingUp = true;
    }
    if (keyCode == 63233) {  // down
        editorMovingDown = true;
    }

    return YES;
}

- (BOOL)ccKeyUp:(NSEvent*)event
{
	NSString* character = [event characters];
    unichar keyCode = [character characterAtIndex:0];
    
	// Player movement
	if (keyCode == 119) {
		movingUp = false;
	} else if (keyCode == 115) {
		movingDown = false;
	}
	if (keyCode == 97) {
		movingLeft = false;
	} else if (keyCode == 100) {
		movingRight = false;
	}
    
    // Player actions
    if (keyCode == 32) {  // space
        deactivatePressed = false;
        deactivating = false;
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
    if (keyCode == 105) {  // i
        editorItemPickEnabled = !editorItemPickEnabled;
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
    if (keyCode == 9) {  // TAB
        ++editorSelectedEnemy;
        if (!state.enemies[editorSelectedEnemy].active) {
            editorSelectedEnemy = 0;
        }
    }
    if (keyCode == 63234) {  // left
        editorMovingLeft = false;
    }
    if (keyCode == 63235) {  // right
        editorMovingRight = false;
    }
    if (keyCode == 63232) {  // up
        editorMovingUp = false;
    }
    if (keyCode == 63233) {  // down
        editorMovingDown = false;
    }
    if (keyCode == 109) {  // m
        for (int i=0; i<MaxEnemyCount; ++i) {
            if (!state.enemies[i].active) {
                state.enemies[i].active = true;
                break;
            }
        }
    }
    if (keyCode == 110) {  // n
        for (int i=MaxEnemyCount-1; i>=0; --i) {
            if (state.enemies[i].active) {
                state.enemies[i].active = false;
                break;
            }
        }
    }
    
    return YES;
}


@end
