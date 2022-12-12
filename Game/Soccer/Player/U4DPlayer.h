//
//  U4DPlayer.hpp
//  UntoldEngine
//
//  Created by Harold Serrano on 11/16/21.
//  Copyright © 2021 Untold Engine Studios. All rights reserved.
//

#ifndef U4DPlayer_hpp
#define U4DPlayer_hpp

#include <stdio.h>
#include "U4DModel.h"
#include "U4DDynamicAction.h"
#include "U4DAnimationManager.h"
#include "CommonProtocols.h"
#include "U4DArrive.h"
#include "U4DPursuit.h"
#include "U4DAvoidance.h"
#include "U4DFlock.h"
#include "U4DWander.h"
#include <map>

namespace U4DEngine{

class U4DTeam;
class U4DPlayerStateInterface;
class U4DPlayerStateManager;

class U4DPlayer:public U4DModel {
    
private:
    
    
    
    U4DPlayerStateManager *stateManager;
    
    //motion accumulator
    U4DVector3n motionAccumulator;
    
    //force direction
    
    U4DVector3n forceMotionAccumulator;
    
    U4DVector3n dribblingDirectionAccumulator;
    
    std::map<std::string, U4DAnimation*> animationMap;
    
public:
    
    int playerIndex;
    U4DTeam *team;
    bool shootBall;
    bool passBall;
    bool haltBall;
    bool dribbleBall;
    bool freeToRun;
    bool standTackleOpponent;
    bool slidingTackle;
    bool allowedToKick;
    U4DVector3n previousPosition;
    
    U4DAnimation *runningAnimation;
    U4DAnimation *idleAnimation;
    U4DAnimation *shootingAnimation;
    U4DAnimation *passingAnimation;
    U4DAnimation *haltAnimation;
    U4DAnimation *jogAnimation;
    U4DAnimation *standTackleAnimation;
    U4DAnimation *slidingTackleAnimation;
    
    U4DAnimationManager *animationManager;
    
    U4DDynamicAction *kineticAction;
    
    U4DArrive arriveBehavior;
    
    U4DPursuit pursuitBehavior;
    
    U4DAvoidance avoidanceBehavior;
    
    U4DFlock flockBehavior;
    
    U4DWander wanderBehavior;
    
    U4DVector3n dribblingDirection;
    
    U4DVector3n navDribbling;
    
    U4DVector3n slidingVelocity;
    
    U4DVector3n homePosition;
    
    bool atHome;
    
    U4DPlayer();
    
    ~U4DPlayer();
    
    //init method. It loads all the rendering information among other things.
    bool init(const char* uModelName);
    
    void update(double dt);
    
    void changeState(U4DPlayerStateInterface* uState);
    
    void setDribblingDirection(U4DVector3n &uDribblingDirection);
    
    void applyForce(float uFinalVelocity, double dt);
    
    void applyVelocity(U4DVector3n &uFinalVelocity, double dt);
    
    void setViewDirection(U4DVector3n &uViewDirection);
    
    void setMoveDirection(U4DVector3n &uMoveDirection);
    
    void setFootPoseSpace();
    
    void updateFootSpaceWithAnimation(U4DAnimation *uAnimation);
    
    void setEnableDribbling(bool uValue);
    
    void setEnableShooting(bool uValue);
    
    void setEnablePassing(bool uValue);
    
    void setEnableHalt(bool uValue);
    
    void setEnableFreeToRun(bool uValue);
    
    void setEnableStandTackle(bool uValue);
    
    void setEnableSlidingTackle(bool uValue);
    
    U4DPlayerStateInterface *getCurrentState();
    
    U4DPlayerStateInterface *getPreviousState();
    
    std::string getCurrentStateName();
    
    //add to team
    void addToTeam(U4DTeam *uTeam);

    U4DTeam *getTeam();
    
    void handleMessage(Message &uMsg);
    
    void setPlayerIndex(int uIndex);

    int getPlayerIndex();
    
    void resetAllFlags();
    
    U4DAnimation *getAnimationForState(std::string uStateName);
    
    void setKeyforAnimation(std::string uAnimationName, U4DAnimation* uAnimation);
    
    U4DAnimation *getAnimationForKey(std::string uAnimationName);
    
};

}

#endif /* U4DPlayer_hpp */
