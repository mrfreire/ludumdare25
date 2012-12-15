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
const int TilesStartX = (1280-TilesCountX*TileWidth)/2;
const int TilesStartY = (720-TilesCountY*TileHeight)/2;

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

struct GameState {
    Tile tiles[TilesCountY][TilesCountX];    
};

@interface GameScene : CCNode {
    GameState state;
    CCSprite* tileSprites[TilesCountY][TilesCountX];
}

+ (CCScene *) scene;

@end
