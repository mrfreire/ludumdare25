//
//  GameProgress.h
//  TheVault
//
//  Created by Manuel Freire on 16/12/12.
//
//

#ifndef __TheVault__Utils__
#define __TheVault__Utils__

#include <strings.h>

struct GameProgress {
    char levelAvailable[32];
    char _padding[512];
    GameProgress()
    {
        bzero(levelAvailable, sizeof(levelAvailable));
        bzero(_padding, sizeof(_padding));
        levelAvailable[0] = true;
    }
};

void saveProgress(const GameProgress&);
GameProgress loadProgress();

#endif /* defined(__TheVault__Utils__) */
