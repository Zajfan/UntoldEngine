//
//  SandboxLogic.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 8/13/20.
//  Copyright © 2020 Untold Engine Studios. All rights reserved.
//

#include "SandboxLogic.h"
#import <TargetConditionals.h>
#include "U4DDirector.h"
#include "CommonProtocols.h"
#include "UserCommonProtocols.h"
#include "SandboxWorld.h"
#include "U4DGameConfigs.h"
#include "U4DScriptManager.h"
#include "U4DCamera.h"

#include "U4DAnimationManager.h"


#include "U4DSceneManager.h"
#include "U4DScene.h"
#include "U4DSceneStateManager.h"
#include "U4DSceneEditingState.h"
#include "U4DScenePlayState.h"



#include "U4DClientManager.h"
#include "U4DLayerManager.h"
#include "U4DLayer.h"
#include "U4DDebugger.h"
#include "U4DCameraInterface.h"
#include "U4DCameraBasicFollow.h"


#include "U4DGameConfigs.h"


SandboxLogic::SandboxLogic():aKeyFlag(false),sKeyFlag(false),wKeyFlag(false),dKeyFlag(false),playerMotionAccumulator(0.0,0.0,0.0){
    
}

SandboxLogic::~SandboxLogic(){
    
}

void SandboxLogic::update(double dt){
   
    
}

void SandboxLogic::init(){
    
    
    
    
}



void SandboxLogic::receiveUserInputUpdate(void *uData){
       
    
    
}
