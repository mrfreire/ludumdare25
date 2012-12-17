//
//  GameProgress.cpp
//  TheVault
//
//  Created by Manuel Freire on 16/12/12.
//
//

#include "GameProgress.h"

#include <cstdio>

GameProgress globalProgress;

void saveProgress(const GameProgress& progress)
{
    FILE* f = fopen("save.bin", "w");
    if (f) {
        fwrite(&progress, sizeof(GameProgress), 1, f);
        fclose(f);
    }
    globalProgress = progress;
}

GameProgress loadProgress()
{
    GameProgress progress;
    FILE* f = fopen("save.bin", "r");
    if (f) {
        fread(&progress, sizeof(GameProgress), 1, f);
        fclose(f);
    } else {
        progress = globalProgress;
    }
    
    return progress;
}

