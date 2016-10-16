//
//  GameController.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 6/10/13.
//  Copyright (c) 2013 Untold Story Studio. All rights reserved.
//

#include "GameController.h"
#include <vector>
#include "CommonProtocols.h"
#include "GameLogic.h"
#include "U4DEntity.h"
#include "U4DCallback.h"
#include "U4DButton.h"
#include "U4DCamera.h"
#include "U4DJoyStick.h"
#include "Earth.h"

void GameController::init(){
    
    U4DEngine::U4DCallback<GameController>* action3Callback=new U4DEngine::U4DCallback<GameController>;
    
    action3Callback->scheduleClassWithMethod(this, &GameController::action);
    
    joyStick=new U4DEngine::U4DJoyStick(-0.5,-0.5,"joyStickBackground.png",124,124,"joystickDriver.png",76,76,action3Callback);
    
    add(joyStick);

 
    U4DEngine::U4DCallback<GameController>* action2Callback=new U4DEngine::U4DCallback<GameController>;
    
    action2Callback->scheduleClassWithMethod(this, &GameController::forward);
    
    myButton=new U4DEngine::U4DButton(0.5,-0.5,102,102,"ButtonA.png","ButtonAPressed.png",action2Callback,U4DEngine::rTouchesBegan);
    add(myButton);
    
   
    
    U4DEngine::U4DCallback<GameController>* actionCallback=new U4DEngine::U4DCallback<GameController>;
    
    actionCallback->scheduleClassWithMethod(this, &GameController::backward);
    
    myButtonB=new U4DEngine::U4DButton(0.2,-0.5,102,102,"ButtonB.png","ButtonBPressed.png",actionCallback,U4DEngine::rTouchesBegan);
    add(myButtonB);
    

}



void GameController::action(){
    
    data+=joyStick->getDataPosition();
    
    data.x*=0.5;
    data.y*=0.1;
    
    U4DEngine::U4DVector3n axisOrientation(0,1,0);
//    U4DEngine::U4DCamera *camera=U4DEngine::U4DCamera::sharedInstance();
//    //camera->rotateBy(-data.x, axisOrientation);
//    controlledU4DObject->rotateBy(-data.x, axisOrientation);

    
    controllerSource=joystick;
    gameModel->controllerAction(&controllerSource);

}

void GameController::forward(){
 
    controllerSource=buttonA;
    gameModel->controllerAction(&controllerSource);

}

void GameController::backward(){

    controllerSource=buttonB;
    gameModel->controllerAction(&controllerSource);

}