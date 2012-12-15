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
const int TileTypesCount = 2;

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

@interface GameScene : CCLayer {
    GameState state;
    CCSprite* tileSprites[TilesCountY][TilesCountX];
    CGSize screenSize;
}

+ (CCScene *) scene;

@end
