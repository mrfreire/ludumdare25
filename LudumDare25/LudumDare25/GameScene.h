//
//  GameScene.h
//  LudumDare25
//
//  Created by Manuel Freire on 15/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

const int TilesCountX = 15;
const int TilesCountY = 15;
const int TileWidth = 40;
const int TileHeight = 40;
const int TilesTotalWidth = TilesCountX*TileWidth;
const int TilesTotalHeight = TilesCountY*TileHeight;
const int TilesStartX = (1280-TilesTotalWidth)/2;
const int TilesStartY = (720-TilesTotalHeight)/2;
const int TilesEndX = TilesStartX + TilesTotalWidth;
const int TilesEndY = TilesStartY + TilesTotalHeight;
const float PlayerSpeed = 150.0f;

enum TileTypes {
    Floor = 0,
    Wall,
    Vault,
    Door,
    Exit,
    
    TileTypesCount
};

const bool TileIsWalkable[TileTypesCount] = {
    true,
    false,
    true,
    false,
    true
};

struct Tile {
    int x, y;
    int strength;
    int type;
    bool isExit;
    
    Tile()
    : strength(1)
    , isExit(false)
    {}
};

struct Player {
    CGPoint position;
    int tileX, tileY;
    float rotation;
    
    Player()
    : position(CGPointZero)
    , tileX(0)
    , tileY(0)
    , rotation(0.0f)
    {}
};

struct GameState {
    Tile tiles[TilesCountY][TilesCountX];
    Player player;
};

@interface GameScene : CCLayer {
    int level;
    GameState state;
    CCSprite* tileSprites[TilesCountY][TilesCountX];
    CCNode* board;
    CCSprite* playerSprite;
    CGSize screenSize;
    bool movingUp;
    bool movingDown;
    bool movingLeft;
    bool movingRight;
    int editorSelectedTile;
    bool finished;
}

+ (CCScene*)sceneWithLevel:(int)level;

- (id)initWithLevel:(int)level;

@end
