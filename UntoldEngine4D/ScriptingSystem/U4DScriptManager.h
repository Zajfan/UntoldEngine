//
//  U4DScriptManager.hpp
//  UntoldEngine
//
//  Created by Harold Serrano on 6/14/21.
//  Copyright © 2021 Untold Engine Studios. All rights reserved.
//

#ifndef U4DScriptManager_hpp
#define U4DScriptManager_hpp

#include <stdio.h>
#include "gravity_compiler.h"
#include "gravity_core.h"
#include "gravity_vm.h"
#include "gravity_macros.h"
#include "gravity_vmmacros.h"
#include "gravity_opcodes.h"
#include "gravity_utils.h"
#include "gravity_hash.h"
#include "gravity_delegate.h"
#include <iostream>
#include <list>
#include <string.h>

namespace U4DEngine {

    enum UserInputListEnum{
            inputElementType,
            inputElementAction,
            joystickDirection,
            inputPosition,
            previousMousePosition,
            mouseDeltaPosition,
            joystickChangeDirection,
            mouseChangeDirection,
            arrowKeyDirection,
            elementUIName,
            dataValue
        };

    class U4DScriptManager {
        
    private:
    
        static U4DScriptManager *instance;
        
        gravity_list_t *userInputList;
        
        
    protected:
        
        U4DScriptManager();
        
        ~U4DScriptManager();
        
    public:
        
        //gravity_closure_t *closure;
        gravity_compiler_t *compiler;
        gravity_vm *vm;
        gravity_delegate_t delegate;
        
        static U4DScriptManager *sharedInstance();
        
        static void freeObjects(gravity_vm *vm, gravity_object_t *obj);
        static void registerClasses (gravity_vm *vm);
        static void reportError(gravity_vm *vm, error_type_t error_type, const char *message, error_desc_t error_desc, void *xdata);
        bool loadScript(std::string uScriptPath);
        bool init();
        void cleanup();
        void loadGameConfigs();
        
        static const char *loadFileCallback (const char *path, size_t *size, uint32_t *fileid, void *xdata, bool *is_static);
        
        void awakeClosure();
        void initClosure();
        void preUpdateClosure(double dt);
        void updateClosure(double dt);
        void update(int uScriptID, double dt);
        void userInputClosure(void *uData);
        void deInitClosure();
        
        void removeItemsInList(gravity_list_t *l);
        void freeUserInputObjects();
        
        //model
        static bool modelLink(gravity_vm *vm, gravity_value_t *args, uint16_t nargs, uint32_t rindex);
        
    };

}

#endif /* U4DScriptManager_hpp */
