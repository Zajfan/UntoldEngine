//
//  U4DScenePreviewState.hpp
//  UntoldEngine
//
//  Created by Harold Serrano on 12/10/22.
//  Copyright © 2022 Untold Engine Studios. All rights reserved.
//

#ifndef U4DScenePreviewState_hpp
#define U4DScenePreviewState_hpp

#include <stdio.h>
#include "U4DSceneStateInterface.h"

namespace U4DEngine {

    /**
    @ingroup scene
    @brief The U4DScenePreviewState class represents the scene Idle state.
    */
    class U4DScenePreviewState:public U4DSceneStateInterface {

    private:
        
        bool safeToChangeState;
        
        bool didGameLogicInit;
        
        U4DScenePreviewState();
        
        ~U4DScenePreviewState();
        
    public:
        
        static U4DScenePreviewState* instance;
        
        static U4DScenePreviewState* sharedInstance();
        
        /**
        @brief enters new state
        @param uScene scene to enter into new state
        */
        void enter(U4DScene *uScene);
        
        /**
        @brief executes current state
        @param uScene scene to execute
        @param dt game tick
        */
        void execute(U4DScene *uScene, double dt);
        
        /**
        @brief Renders current scene
        @param uScene scene to render
        @param uRenderEncoder metal render encoder
        */
        void render(U4DScene *uScene, id <MTLCommandBuffer> uCommandBuffer);
        
        
        
        /**
        @brief exits current state
        @param uScene scene to exit
        */
        void exit(U4DScene *uScene);
        
        /**
        @brief true if is safe to change states
        @param uScene current scene
        */
        bool isSafeToChangeState(U4DScene *uScene);
        
    };

}
#endif /* U4DScenePreviewState_hpp */
