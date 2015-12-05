//
//  ObjectManager.h
//  UntoldEngine
//
//  Created by Harold Serrano on 6/22/13.
//  Copyright (c) 2013 Untold Story Studio. All rights reserved.
//

#ifndef __UntoldEngine__U4DEntityManager__
#define __UntoldEngine__U4DEntityManager__

#include <iostream>
#include <vector>

namespace U4DEngine {
    
    class U4DEntity;
    class U4DWorld;
    class U4DCollisionEngine;
    class U4DVisibleEntity;
    class U4DPhysicsEngine;
    class U4DCollisionEngine;
    class U4DCollisionData;
    class U4DTouchesController;
    class U4DControllerInterface;
    class U4DGravityForceGenerator;
    class U4DDragForceGenerator;
    class U4DIntegrator;
    class U4DDynamicModel;
    class U4DCollisionAlgorithm;
    class U4DManifoldGeneration;
    class U4DVector3n;
    
}


namespace U4DEngine {
    
    /**
     *  Class manager for all objects in the engine
     */
    class U4DEntityManager{

    private:
        
        U4DPhysicsEngine *physicsEngine;
     
        U4DCollisionEngine *collisionEngine;
        
        U4DControllerInterface *touchController;
        
        U4DIntegrator *integratorMethod;
        
        U4DCollisionAlgorithm *collisionAlgorithm;
        
        U4DManifoldGeneration *manifoldGenerationAlgorithm;
        
    public:
        
        U4DEntity *rootEntity;
        
        U4DEntityManager();
     
        ~U4DEntityManager();
        
        U4DEntityManager(const U4DEntityManager& value){};

        U4DEntityManager& operator=(const U4DEntityManager& value){return *this;};
     
        void draw();
        
        void update(float dt);
        
        void setRootEntity(U4DVisibleEntity* uRootEntity);
        
        void setGravity(U4DVector3n& uGravity);
        
        
    };
    
}


#endif /* defined(__UntoldEngine__U4DEntityManager__) */
