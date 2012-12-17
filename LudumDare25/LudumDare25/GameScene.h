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
const int MaxEnemyCount = 32;
const int MaxItemCount = 32;
const float PlayerSpeed = 150.0f;
const float EnemyWalkSpeed = 40.0f;
const float EnemyRunSpeed = 150.0f;
const float EnemyWaitDuration = 4.0f;
const float DetectionThreshold = 0.3f;  // proportion that can be seen before being detected
const int ItemWidth = 20;
const int ItemHeight = 40;
const int DoorOpeningTime = 5;
const int AmbientLight = 100;
const int LightQuant = 15;
const int LightAbsorption = 8;
const int LightReach = 9;

enum ItemTypes {
    Cash,
    Light1,
    Light2,
    Light3,
    Light4,
    
    ItemTypesCount
};

enum TileTypes {
    Floor = 0,
    Wall,
    Vault,
    VaultDoor,
    Exit,
    Door,
    OpenDoor,
    
    TileTypesCount
};

enum Direction {
    North = 270,
    South = 90,
    East = 0,
    West = 180
};

const bool TileIsWalkable[TileTypesCount] = {
    true,
    false,
    true,
    false,
    true,
    false,
    true
};

struct Tile {
    int x, y;
    int light;
    int type;
    bool isExit;
    
    Tile()
    : light(0)
    , isExit(false)
    {}
};

struct Player {
    CGPoint position;
    int tileX, tileY;
    int rotation;
    char _padding[50];
    
    Player()
    : position(CGPointZero)
    , tileX(0)
    , tileY(0)
    , rotation(0)
    {
        bzero(_padding, sizeof(_padding));
    }
};

struct Enemy : Player {
    int state;
    int substate;
    int patrolTileA[2];
    int patrolTileB[2];
    float dx, dy;
    bool active;
    bool _pad1;
    bool _pad2;
    bool _pad3;
    double stateParams[2];
    int patrolRotationA[4];
    int patrolRotationB[4];
    char _padding[23];
    
    Enemy()
    : state(0)
    , substate(0)
    , active(false)
    , dx(0.0f)
    , dy(0.0f)
    , _pad1(false)
    , _pad2(false)
    , _pad3(false)
    {
        patrolTileA[0] = 0;
        patrolTileA[1] = 0;
        patrolTileB[0] = 0;
        patrolTileB[1] = 0;
        patrolRotationA[0] = 0;
        patrolRotationA[1] = 0;
        patrolRotationA[2] = 180;
        patrolRotationA[3] = 270;
        patrolRotationB[0] = 0;
        patrolRotationB[1] = 0;
        patrolRotationB[2] = 180;
        patrolRotationB[3] = 270;
        bzero(_padding, sizeof(_padding));
    }
};

struct Item {
    int type;
    int tileX;
    int tileY;
    bool collected;
    bool mustBeCollected;
    bool active;
    bool _pad1;
    
    Item()
    : type(0)
    , tileX(0)
    , tileY(0)
    , collected(false)
    , mustBeCollected(false)
    , active(false)
    , _pad1(false)
    {}        
};

struct GameState {
    Tile tiles[TilesCountY][TilesCountX];
    Player player;
    Enemy enemies[MaxEnemyCount];
    Item items[MaxItemCount];
    bool _padding[2000-MaxItemCount*sizeof(Item)];
    
    GameState()
    {
        bzero(_padding, sizeof(_padding));
    }
};

@interface GameScene : CCLayer {
    int level;
    GameState state;
    CCSprite* tileSprites[TilesCountY][TilesCountX];
    CCNode* board;
    CCSprite* playerSprite;
    CCSprite* enemySprites[MaxEnemyCount];
    CCSprite* itemSprites[MaxItemCount];
    CGSize screenSize;
    
    double levelTime;
    
    bool paused;
    
    bool movingUp;
    bool movingDown;
    bool movingLeft;
    bool movingRight;
    
    int editorSelectedTile;
    int editorSelectedEnemy;
    bool editorItemPickEnabled;
    bool editorMovingUp;
    bool editorMovingDown;
    bool editorMovingLeft;
    bool editorMovingRight;
    
    bool finished;
    bool lost;
    int detectedBy;
    
    bool deactivatePressed;
    bool deactivating;
    double deactivateStartTime;
    int tileBeingDeactivated[2];
    CCLayer* deactivatingLayer;
    CCLabelTTF* deactivationCountdownLabel;
    
    CCLayer* pauseLayer;
    
    int itemsInInventory;
    
    bool hasKnife;
    bool usingKnife;
}

+ (CCScene*)sceneWithLevel:(int)level;

- (id)initWithLevel:(int)level;

@end
