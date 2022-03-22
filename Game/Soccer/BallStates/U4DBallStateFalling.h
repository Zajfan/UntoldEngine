//
//  U4DBallStateFalling.hpp
//  UntoldEngine
//
//  Created by Harold Serrano on 3/4/22.
//  Copyright © 2022 Untold Engine Studios. All rights reserved.
//

#ifndef U4DBallStateFalling_hpp
#define U4DBallStateFalling_hpp

#include <stdio.h>
#include "U4DBallStateInterface.h"

namespace U4DEngine {

    class U4DBallStateFalling:public U4DBallStateInterface {

    private:

        U4DBallStateFalling();
        
        ~U4DBallStateFalling();
        
    public:
        
        static U4DBallStateFalling* instance;
        
        static U4DBallStateFalling* sharedInstance();
        
        void enter(U4DBall *uBall);
        
        void execute(U4DBall *uBall, double dt);
        
        void exit(U4DBall *uBall);
        
        bool isSafeToChangeState(U4DBall *uBall);
        
        bool handleMessage(U4DBall *uBall, Message &uMsg);
        
    };

}
#endif /* U4DBallStateFalling_hpp */
