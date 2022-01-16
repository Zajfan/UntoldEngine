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

#include "U4DPlayerStateIdle.h"
#include "U4DPlayerStateDribbling.h"
#include "U4DPlayerStateShooting.h"
#include "U4DPlayerStatePass.h"
#include "U4DPlayerStateIntercept.h"
#include "U4DPlayerStateFree.h"
#include "U4DPlayerStateFlock.h"

#include "U4DSceneManager.h"
#include "U4DScene.h"
#include "U4DSceneStateManager.h"
#include "U4DSceneEditingState.h"
#include "U4DScenePlayState.h"

#include "U4DTeam.h"
#include "U4DBall.h"

#include "U4DClientManager.h"
#include "U4DLayerManager.h"
#include "U4DLayer.h"
#include "U4DDebugger.h"
#include "U4DCameraInterface.h"
#include "U4DCameraBasicFollow.h"

#include "U4DTeamStateAttacking.h"
#include "U4DTeamStateDefending.h"

#include "U4DGameConfigs.h"
#include "U4DMatchRef.h"

SandboxLogic::SandboxLogic():pPlayer(nullptr),teamA(nullptr),teamB(nullptr),pGround(nullptr){
    
}

SandboxLogic::~SandboxLogic(){
    
}

void SandboxLogic::update(double dt){
    
    if(teamA!=nullptr && teamB!=nullptr){
        teamA->update(dt);
        teamB->update(dt);
    }

    
    if (pGround!=nullptr) {
        
        pGround->shadeField(pPlayer);
        
    }
    
    U4DEngine::U4DMatchRef *matchRef=U4DEngine::U4DMatchRef::sharedInstance();
    matchRef->update(dt);
    
    
}

void SandboxLogic::init(){
    
    U4DEngine::U4DLogger *logger=U4DEngine::U4DLogger::sharedInstance();
    
    //1. Get a pointer to the LevelOneWorld object
    SandboxWorld* pEarth=dynamic_cast<SandboxWorld*>(getGameWorld());

    U4DEngine::U4DBall *ball=U4DEngine::U4DBall::sharedInstance();
    if (ball->init("ball")) {
        pEarth->addChild(ball);
    }
    
    //Instantiate the camera
    U4DEngine::U4DCamera *camera=U4DEngine::U4DCamera::sharedInstance();

    //Instantiate the camera interface and the type of camera you desire
    U4DEngine::U4DCameraInterface *cameraBasicFollow=U4DEngine::U4DCameraBasicFollow::sharedInstance();

    U4DEngine::U4DDirector *director=U4DEngine::U4DDirector::sharedInstance();

    //get device type
    if(director->getDeviceOSType()==U4DEngine::deviceOSIOS){

        U4DEngine::U4DDebugger *debugger=U4DEngine::U4DDebugger::sharedInstance();
        debugger->setEnableDebugger(true, pEarth);

        //create layer manager
        U4DEngine::U4DLayerManager *layerManager=U4DEngine::U4DLayerManager::sharedInstance();

        //set this view (U4DWorld subclass) to the layer Manager
        layerManager->setWorld(pEarth);

        //create Layers
        U4DEngine::U4DLayer* mainMenuLayer=new U4DEngine::U4DLayer("menuLayer");

        //Create buttons to add to the layer
        U4DEngine::U4DButton *buttonA=new U4DEngine::U4DButton("buttonA",0.6,-0.5,100.0,100.0,"ButtonA.png");
        U4DEngine::U4DButton *buttonB=new U4DEngine::U4DButton("buttonA",0.75,-0.5,100.0,100.0,"ButtonA.png");
        U4DEngine::U4DJoystick *joystick=new U4DEngine::U4DJoystick("joystick",-0.7,-0.5,"joyStickBackground.png",150.0,150.0,"joyStickDriver.png");

        //add the buttons to the layer
        mainMenuLayer->addChild(joystick);
        mainMenuLayer->addChild(buttonA);
        mainMenuLayer->addChild(buttonB);

        layerManager->addLayerToContainer(mainMenuLayer);

        //Set the parameters for the camera. Such as which model the camera will target, and the offset positions
        //cameraBasicFollow->setParameters(ball,0.0,30.0,-35.0);
        cameraBasicFollow->setParametersWithBoxTracking(ball,0.0,25.0,-35.0,U4DEngine::U4DPoint3n(-1.0,-1.0,-1.0),U4DEngine::U4DPoint3n(1.0,1.0,1.0));

        //push layer
        layerManager->pushLayer("menuLayer");

        U4DEngine::U4DCamera *camera=U4DEngine::U4DCamera::sharedInstance();

        camera->translateTo(0.0,35.0,-42.0);



    }else if(director->getDeviceOSType()==U4DEngine::deviceOSMACX){

        U4DEngine::U4DText *instructions=new U4DEngine::U4DText("uiFont");
        instructions->setText("Press P to play. Press U to pause\n Mouse to dribble. Left click shoot");
        instructions->translateTo(-0.2,-0.3, 0.0);

        pEarth->addChild(instructions,-20);

        cameraBasicFollow->setParametersWithBoxTracking(ball,0.0,25.0,-45.0,U4DEngine::U4DPoint3n(-3.0,-3.0,-3.0),U4DEngine::U4DPoint3n(3.0,3.0,3.0));

    }

    //set the camera behavior
    camera->setCameraBehavior(cameraBasicFollow);
    
    //2. Search for the player object
    pPlayer=dynamic_cast<U4DEngine::U4DPlayer*>(pEarth->searchChild("player0.0"));


    if(pPlayer!=nullptr){
        logger->log("player with name %s found",pPlayer->getName().c_str());



    }
    
    pGround=dynamic_cast<U4DEngine::U4DField*>(pEarth->searchChild("field0"));
    U4DEngine::U4DGoalPost* pGoalPost0=dynamic_cast<U4DEngine::U4DGoalPost*>(pEarth->searchChild("fieldgoal.0"));
    U4DEngine::U4DGoalPost* pGoalPost1=dynamic_cast<U4DEngine::U4DGoalPost*>(pEarth->searchChild("fieldgoal.1"));
    U4DEngine::U4DPlayer *p1=dynamic_cast<U4DEngine::U4DPlayer*>(pEarth->searchChild("player0.1"));

    U4DEngine::U4DPlayer *p2=dynamic_cast<U4DEngine::U4DPlayer*>(pEarth->searchChild("player0.2"));


    U4DEngine::U4DPlayer *eP0=dynamic_cast<U4DEngine::U4DPlayer*>(pEarth->searchChild("oppositeplayer0.0"));
    U4DEngine::U4DPlayer *eP1=dynamic_cast<U4DEngine::U4DPlayer*>(pEarth->searchChild("oppositeplayer0.1"));
    U4DEngine::U4DPlayer *eP2=dynamic_cast<U4DEngine::U4DPlayer*>(pEarth->searchChild("oppositeplayer0.2"));
    
    teamA=new U4DEngine::U4DTeam();
    teamB=new U4DEngine::U4DTeam();

    teamA->addPlayer(pPlayer);
    teamA->addPlayer(p1);
    teamA->addPlayer(p2);
    
    teamB->addPlayer(eP0);
    teamB->addPlayer(eP1);
    teamB->addPlayer(eP2);
    teamB->aiTeam=true;
    //set controlling player
    
    teamA->setActivePlayer(pPlayer);
    teamB->setActivePlayer(eP0);
    
    //pPlayer->setEnableFreeToRun(true);
    
    
    teamA->updateFormation();
    teamA->initAnalyzerSchedulers();
    
    teamB->updateFormation();
    teamB->initAnalyzerSchedulers();
    
    teamA->setOppositeTeam(teamB);
    teamB->setOppositeTeam(teamA);
    
    teamA->changeState(U4DEngine::U4DTeamStateAttacking::sharedInstance());
    teamB->changeState(U4DEngine::U4DTeamStateDefending::sharedInstance());
    
    U4DEngine::U4DMatchRef *matchRef=U4DEngine::U4DMatchRef::sharedInstance();
    matchRef->initMatch(teamA, teamB, pGoalPost0, pGoalPost1, pGround);
}



void SandboxLogic::receiveUserInputUpdate(void *uData){
    
    U4DEngine::CONTROLLERMESSAGE controllerInputMessage=*(U4DEngine::CONTROLLERMESSAGE*)uData;
    
    if(teamA!=nullptr){
        pPlayer=teamA->getActivePlayer();
    }
    
    if (pPlayer!=nullptr) {
      
        switch (controllerInputMessage.inputElementType) {

            case U4DEngine::uiButton:

                if(controllerInputMessage.inputElementAction==U4DEngine::uiButtonPressed){


                    if (controllerInputMessage.elementUIName.compare("buttonA")==0) {

                        //std::cout<<"Button A pressed"<<std::endl;


                    }

                }else if (controllerInputMessage.inputElementAction==U4DEngine::uiButtonReleased){

                    if (controllerInputMessage.elementUIName.compare("buttonA")==0) {

                        if(pPlayer->getTeam()->getCurrentState()==U4DEngine::U4DTeamStateAttacking::sharedInstance()){
                            
                            pPlayer->setEnablePassing(true);
                            U4DEngine::U4DLogger *logger=U4DEngine::U4DLogger::sharedInstance();
                            logger->log("passing");
                            
                        }else if(pPlayer->getTeam()->getCurrentState()==U4DEngine::U4DTeamStateDefending::sharedInstance()){
                            
                            pPlayer->setEnableSlidingTackle(true);
                            U4DEngine::U4DLogger *logger=U4DEngine::U4DLogger::sharedInstance();
                            logger->log("slide tackling");
                        }
                        
                    }else if(controllerInputMessage.elementUIName.compare("buttonB")==0){
                        
                        if(pPlayer->getTeam()->getCurrentState()==U4DEngine::U4DTeamStateAttacking::sharedInstance()){
                            pPlayer->setEnableShooting(true);
                            U4DEngine::U4DLogger *logger=U4DEngine::U4DLogger::sharedInstance();
                            logger->log("shooting");
                        }
                        
                        
                    }

                }

                break;

            case U4DEngine::uiSlider:

                if(controllerInputMessage.inputElementAction==U4DEngine::uiSliderMoved){


                    if (controllerInputMessage.elementUIName.compare("sliderA")==0) {

                        

                    }else if(controllerInputMessage.elementUIName.compare("sliderB")==0){



                    }

                }

                break;

            case U4DEngine::uiJoystick:

            if(controllerInputMessage.inputElementAction==U4DEngine::uiJoystickMoved){


                if (controllerInputMessage.elementUIName.compare("joystick")==0) {

                    //Get the direction of the joystick
                    U4DEngine::U4DVector2n digitalJoystickDirection=controllerInputMessage.joystickDirection;
                    
                    U4DEngine::U4DVector3n joystickDirection3d(digitalJoystickDirection.x,0.0,digitalJoystickDirection.y);

                    if(pPlayer->getCurrentState()==U4DEngine::U4DPlayerStateFree::sharedInstance()){
                        pPlayer->setEnableFreeToRun(true);
                    }else if(pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateDribbling::sharedInstance()&& pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateShooting::sharedInstance()&& pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateIntercept::sharedInstance()&& pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStatePass::sharedInstance()){

                        //pPlayer->changeState(U4DEngine::U4DPlayerStateDribbling::sharedInstance());
                        pPlayer->setEnableDribbling(true);
                    }
                
                    pPlayer->setDribblingDirection(joystickDirection3d);

                }

            }else if (controllerInputMessage.inputElementAction==U4DEngine::uiJoystickReleased){

                if (controllerInputMessage.elementUIName.compare("joystick")==0) {

                    //std::cout<<"joystick released"<<std::endl;
//                    if(pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateShooting::sharedInstance()){
//                        pPlayer->changeState(U4DEngine::U4DPlayerStateIdle::sharedInstance());
//                    }
                    
                    pPlayer->setEnableHalt(true);

                }

            }

            break;

            case U4DEngine::uiCheckbox:

                if(controllerInputMessage.inputElementAction==U4DEngine::uiCheckboxPressed){


                    if (controllerInputMessage.elementUIName.compare("checkboxA")==0) {



                    }else if(controllerInputMessage.elementUIName.compare("checkboxB")==0){


                    }

                }

                break;

            case U4DEngine::mouseLeftButton:
            {
                //4. If button was pressed
                if (controllerInputMessage.inputElementAction==U4DEngine::mouseLeftButtonPressed) {

                    //std::cout<<"left clicked"<<std::endl;

                    //5. If button was released
                }else if(controllerInputMessage.inputElementAction==U4DEngine::mouseLeftButtonReleased){

//                    pPlayer->setEnableShooting(true);
//                    U4DEngine::U4DLogger *logger=U4DEngine::U4DLogger::sharedInstance();
//                    logger->log("shooting");
                }
            }

                break;
                
            case U4DEngine::mouseRightButton:
            {
                //4. If button was pressed
                if (controllerInputMessage.inputElementAction==U4DEngine::mouseRightButtonPressed) {

                    //std::cout<<"left clicked"<<std::endl;

                    //5. If button was released
                }else if(controllerInputMessage.inputElementAction==U4DEngine::mouseRightButtonReleased){

//                    pPlayer->setEnablePassing(true);
//                    U4DEngine::U4DLogger *logger=U4DEngine::U4DLogger::sharedInstance();
//                    logger->log("passing");
                }
            }

                break;
                
            case U4DEngine::macArrowKey:
            
            {
                
                //4. If button was pressed
                if (controllerInputMessage.inputElementAction==U4DEngine::macArrowKeyActive) {

                    if(pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateDribbling::sharedInstance() && pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateShooting::sharedInstance()){
                        pPlayer->changeState(U4DEngine::U4DPlayerStateDribbling::sharedInstance());
                    }
                    
                    U4DEngine::U4DVector2n arrowkeyDirection=controllerInputMessage.arrowKeyDirection;
                    U4DEngine::U4DVector3n dribblingDirection(arrowkeyDirection.x,0.0,arrowkeyDirection.y);
                    
                    pPlayer->setDribblingDirection(dribblingDirection);

                    //5. If button was released
                }else if(controllerInputMessage.inputElementAction==U4DEngine::macArrowKeyActive){
                    
                    if(pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateShooting::sharedInstance()){
                        pPlayer->changeState(U4DEngine::U4DPlayerStateIdle::sharedInstance());
                    }
                }
            }
                
                break;

                //3. Did Button A on a mobile or game controller receive an action from the user (Key A on a Mac)
            case U4DEngine::macKeyA:
            {
                
                //4. If button was pressed
                if (controllerInputMessage.inputElementAction==U4DEngine::macKeyPressed) {


                    //5. If button was released
                }else if(controllerInputMessage.inputElementAction==U4DEngine::macKeyReleased){
                    
                    if(pPlayer->getTeam()->getCurrentState()==U4DEngine::U4DTeamStateAttacking::sharedInstance()){
                        
                        pPlayer->setEnablePassing(true);
                        U4DEngine::U4DLogger *logger=U4DEngine::U4DLogger::sharedInstance();
                        logger->log("passing");
                        
                    }else if(pPlayer->getTeam()->getCurrentState()==U4DEngine::U4DTeamStateDefending::sharedInstance()){
                        
                        pPlayer->setEnableSlidingTackle(true);
                        U4DEngine::U4DLogger *logger=U4DEngine::U4DLogger::sharedInstance();
                        logger->log("slide tackling");
                    }
                    
                    
//                    if(pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateShooting::sharedInstance()){
//                        pPlayer->changeState(U4DEngine::U4DPlayerStateIdle::sharedInstance());
//                    }
                }else if(controllerInputMessage.inputElementAction==U4DEngine::macKeyActive){
                 
//                    if(pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateDribbling::sharedInstance() && pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateShooting::sharedInstance()){
//                        pPlayer->changeState(U4DEngine::U4DPlayerStateDribbling::sharedInstance());
//                    }
//
//                    U4DEngine::U4DVector3n dribblingDirection(-1.0,0.0,0.0);
//                    pPlayer->setDribblingDirection(dribblingDirection);
                }
            }

                break;

                //6. Did Button B on a mobile or game controller receive an action from the user. (Key D on Mac)
            case U4DEngine::macKeyD:
            {
                //7. If button was pressed
                if (controllerInputMessage.inputElementAction==U4DEngine::macKeyPressed) {
                    
                    
                    
                    //8. If button was released
                }else if(controllerInputMessage.inputElementAction==U4DEngine::macKeyReleased){

                    if(pPlayer->getTeam()->getCurrentState()==U4DEngine::U4DTeamStateAttacking::sharedInstance()){
                        pPlayer->setEnableShooting(true);
                        U4DEngine::U4DLogger *logger=U4DEngine::U4DLogger::sharedInstance();
                        logger->log("shooting");
                    }
                    
//                    if(pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateShooting::sharedInstance()){
//                        pPlayer->changeState(U4DEngine::U4DPlayerStateIdle::sharedInstance());
//                    }
                    
                }else if(controllerInputMessage.inputElementAction==U4DEngine::macKeyActive){
//                    if(pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateDribbling::sharedInstance()&& pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateShooting::sharedInstance()){
//                        pPlayer->changeState(U4DEngine::U4DPlayerStateDribbling::sharedInstance());
//                    }
//
//                    U4DEngine::U4DVector3n dribblingDirection(1.0,0.0,0.0);
//
//                    pPlayer->setDribblingDirection(dribblingDirection);
                }

            }

                break;

            case U4DEngine::macKeyW:
            {
                //4. If button was pressed
                if (controllerInputMessage.inputElementAction==U4DEngine::macKeyPressed) {

                    
                    
                    //5. If button was released
                }else if(controllerInputMessage.inputElementAction==U4DEngine::macKeyReleased){
                    
//                    if(pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateShooting::sharedInstance()){
//                        pPlayer->changeState(U4DEngine::U4DPlayerStateIdle::sharedInstance());
//                    }
                
                }else if(controllerInputMessage.inputElementAction==U4DEngine::macKeyActive){
                    
//                    if(pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateDribbling::sharedInstance()&& pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateShooting::sharedInstance()){
//                        pPlayer->changeState(U4DEngine::U4DPlayerStateDribbling::sharedInstance());
//                    }
//
//                    U4DEngine::U4DVector3n dribblingDirection(0.0,0.0,1.0);
//
//                    pPlayer->setDribblingDirection(dribblingDirection);
                }
            }
                break;

            case U4DEngine::macKeyS:
            {
                //4. If button was pressed
                if (controllerInputMessage.inputElementAction==U4DEngine::macKeyPressed) {

                    
                    
                    //5. If button was released
                }else if(controllerInputMessage.inputElementAction==U4DEngine::macKeyReleased){

//                    if(pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateShooting::sharedInstance()){
//                        pPlayer->changeState(U4DEngine::U4DPlayerStateIdle::sharedInstance());
//                    }
                    if(pPlayer->getCurrentState()==U4DEngine::U4DPlayerStateFree::sharedInstance()){
                        pPlayer->changeState(U4DEngine::U4DPlayerStateIdle::sharedInstance());
                    }else{
                        pPlayer->setEnableHalt(true);
                    }
                    
                    
                    
                }else if(controllerInputMessage.inputElementAction==U4DEngine::macKeyActive){
                    
//                    if(pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateDribbling::sharedInstance()&& pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateShooting::sharedInstance()){
//                        pPlayer->changeState(U4DEngine::U4DPlayerStateDribbling::sharedInstance());
//                    }
//
//                    U4DEngine::U4DVector3n dribblingDirection(0.0,0.0,-1.0);
//
//                    pPlayer->setDribblingDirection(dribblingDirection);
                    
                }

            }
                break;

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
            //both keys P and U are used to set the scene into a Play or Pause status, respectively. They are only used for testing
            case U4DEngine::macKeyP:
            {
                
                //4. If button was pressed
                if (controllerInputMessage.inputElementAction==U4DEngine::macKeyPressed) {

                    
                    
                    //5. If button was released
                }else if(controllerInputMessage.inputElementAction==U4DEngine::macKeyReleased){
  
                    U4DEngine::U4DLogger *logger=U4DEngine::U4DLogger::sharedInstance();
                    
                    U4DEngine::U4DSceneManager *sceneManager=U4DEngine::U4DSceneManager::sharedInstance();
                    U4DEngine::U4DScene *scene=sceneManager->getCurrentScene();
                    U4DEngine::U4DSceneStateManager *sceneStateManager=scene->getSceneStateManager();
                    
                    if(sceneStateManager->getCurrentState()==U4DEngine::U4DSceneEditingState::sharedInstance()){
                        //change scene state to edit mode
                        scene->getSceneStateManager()->changeState(U4DEngine::U4DScenePlayState::sharedInstance());
                        
                    }else if(sceneStateManager->getCurrentState()==U4DEngine::U4DScenePlayState::sharedInstance()){
                        
                        scene->setPauseScene(false);
                    
                    }
                    
                    scene->setAnchorMouse(true);
                
                    [NSCursor hide];
                    
                    logger->log("Game was resumed");
                    
                }

            }
                break;
                
            case U4DEngine::macKeyU:
            {
                
                //4. If button was pressed
                if (controllerInputMessage.inputElementAction==U4DEngine::macKeyPressed) {

                    
                    
                    //5. If button was released
                }else if(controllerInputMessage.inputElementAction==U4DEngine::macKeyReleased){
  
                    U4DEngine::U4DLogger *logger=U4DEngine::U4DLogger::sharedInstance();
                    
                    U4DEngine::U4DSceneManager *sceneManager=U4DEngine::U4DSceneManager::sharedInstance();
                    U4DEngine::U4DScene *scene=sceneManager->getCurrentScene();
                    
                    U4DEngine::U4DSceneStateManager *sceneStateManager=scene->getSceneStateManager();
                    
                    if (sceneStateManager->getCurrentState()==U4DEngine::U4DScenePlayState::sharedInstance()) {
                        
                        //change scene state to pause
                        scene->setPauseScene(true);
                        
                        logger->log("Game was paused");
                        
                        scene->setAnchorMouse(false);
                    
                        [NSCursor unhide];
                        
                    }
                    
                }

            }
                break;
#endif

            case U4DEngine::macShiftKey:
            {
                //4. If button was pressed
                if (controllerInputMessage.inputElementAction==U4DEngine::macKeyPressed) {


                    //5. If button was released
                }else if(controllerInputMessage.inputElementAction==U4DEngine::macKeyReleased){


                }

            }
                break;

            case U4DEngine::padButtonA:

                if (controllerInputMessage.inputElementAction==U4DEngine::padButtonPressed) {



                }else if(controllerInputMessage.inputElementAction==U4DEngine::padButtonReleased){

                }

                break;

            case U4DEngine::padButtonB:

                if (controllerInputMessage.inputElementAction==U4DEngine::padButtonPressed) {



                }else if(controllerInputMessage.inputElementAction==U4DEngine::padButtonReleased){

                }

                break;

            case U4DEngine::padRightTrigger:

                if (controllerInputMessage.inputElementAction==U4DEngine::padButtonPressed) {



                }else if(controllerInputMessage.inputElementAction==U4DEngine::padButtonReleased){

                }

                break;

            case U4DEngine::padLeftTrigger:

                if (controllerInputMessage.inputElementAction==U4DEngine::padButtonPressed) {



                }else if(controllerInputMessage.inputElementAction==U4DEngine::padButtonReleased){


                }

            break;

            case U4DEngine::padLeftThumbstick:

                if(controllerInputMessage.inputElementAction==U4DEngine::padThumbstickMoved){

                   //Get joystick direction
                   U4DEngine::U4DVector3n joystickDirection(controllerInputMessage.joystickDirection.x,0.0,controllerInputMessage.joystickDirection.y);




               }else if (controllerInputMessage.inputElementAction==U4DEngine::padThumbstickReleased){




               }

            break;

            case U4DEngine::mouse:
            {

                if(controllerInputMessage.inputElementAction==U4DEngine::mouseActiveDelta){

                    //SNIPPET TO USE FOR MOUSE DELTA POSITION
                                      
                    //Get the delta movement of the mouse
                    U4DEngine::U4DVector2n delta=controllerInputMessage.mouseDeltaPosition;
                    //the y delta should be flipped
                    delta.y*=-1.0;

                    //The following snippet will determine which way to rotate the model depending on the motion of the mouse

                    delta.normalize();

                    U4DEngine::U4DVector3n axis;

                    U4DEngine::U4DVector3n mousedirection(delta.x,0.0,delta.y);

                    if(pPlayer->getCurrentState()==U4DEngine::U4DPlayerStateFree::sharedInstance()){
                        
                        pPlayer->setEnableFreeToRun(true);
                    
                    }else if(pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateDribbling::sharedInstance()&& pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateShooting::sharedInstance()&& pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStateIntercept::sharedInstance()&& pPlayer->getCurrentState()!=U4DEngine::U4DPlayerStatePass::sharedInstance()){

                        //pPlayer->changeState(U4DEngine::U4DPlayerStateDribbling::sharedInstance());
                        pPlayer->setEnableDribbling(true);
                    
                    }
                    
                    
                    
                    pPlayer->setDribblingDirection(mousedirection);

                }else if(controllerInputMessage.inputElementAction==U4DEngine::mouseInactive){

                    //std::cout<<"Mouse stopped"<<std::endl;
                    
                }

            }

                break;

            default:
                break;
        }
        
    }
    
} 
