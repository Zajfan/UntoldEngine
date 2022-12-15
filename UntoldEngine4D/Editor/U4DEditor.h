//
//  U4DEditor.hpp
//  UntoldEngine
//
//  Created by Harold Serrano on 11/26/22.
//  Copyright © 2022 Untold Engine Studios. All rights reserved.
//

#ifndef U4DEditor_hpp
#define U4DEditor_hpp

#include <stdio.h>
#include <map>
#include "U4DEditorStateManager.h"
#include "U4DEntity.h"
#include "U4DVector3n.h"
#include "U4DPlaneMesh.h"
#include "U4DPlayer.h"
#include "U4DCircleMesh.h"
#import <TargetConditionals.h>
#if TARGET_OS_MAC && !TARGET_OS_IPHONE
#include "imgui.h"
#include "ImGuiFileDialog.h"
#include "ImGuizmo.h"

#endif

namespace U4DEngine {

class U4DEditor {
private:
    
    static U4DEditor *instance;
    U4DEditorStateManager *stateManager;
    
    U4DPlayer *previewPlayer;
    U4DCircleMesh *circleMinorMesh;
    U4DCircleMesh *circleMajorMesh;
    ImGuizmo::OPERATION mCurrentGizmoOperation;
    
    U4DVector3n childPosition;
    U4DVector3n childOrientation;

    float entityPosition[3];
    float entityOrientation[3];
    
    bool assetIsSelected=false;
    std::string assetSelectedName;
    std::string assetSelectedTypeName;
    std::string assetSelectedPipelineName;
    
    bool ScrollToBottom=true;
    bool rightMouseActive=false;
    
    bool serialiazeFlag=false;
    bool deserializeFlag=false;
    bool serialiazeAttributeFlag=false;
    bool deserializeAttributeFlag=false;
    ImGuiFileDialog serializeFileDialog;
    std::string sceneFilePath;
    std::string sceneFilePathName;
    
    U4DPlaneMesh *fieldPlane;
    bool scalePlane;
    bool scaleMinorCircle;
    bool scaleMajorCircle;
    
    bool lookingForScriptFile=false;
    ImGuiFileDialog gravityFileDialog;
    std::string scriptFilePathName;
    std::string scriptFilePath;
    bool scriptFilesFound=false;
    bool scriptLoadedSuccessfully=false;
    bool showAttributesFlag=false;
    int zonesCreated;
    std::string stateSelectedTypeName;
    std::string animationSelectedTypeName;
    
    std::map<std::string,U4DPlayerStateInterface*> playerStatesMap;
    
protected:
    U4DEditor();
    ~U4DEditor();
public:
    
    U4DEntity *activeChild;
    U4DVector3n prevCameraPosition;
    U4DVector3n prevCameraOrientation;
    
    static U4DEditor* sharedInstance();
    
    void showEditor();
    void changeState(U4DEditorStateInterface* uState);
    
    void showProperties();
    void showOutputLog();
    void showControls();
    void cameraControls();
    void guizmoControls();
    void showAssets();
    void showScenegraph();
    void showMenu();
    void showAttribMenu();
    void showEntityProperty();
    void createFieldPlane();
    void showFieldPlane();
    void divideZones();
    void destroyFieldPlane();
    void showGameConfigsScript();
    void showAttributes();
    
    void removeFieldZones();
    
    void showStatesProperties();
    
    void loadPreviewPlayer();
    void previewPlayerState();
    void unloadPreviewPlayer();
    void removeEverything();
    void restoreEverything();
    
    void setKeyForState(std::string uKey,U4DPlayerStateInterface* uState);
    U4DPlayerStateInterface *getStateFromKey(std::string uKey);
    std::vector<std::string> getRegisteredStates();
};

}

#endif /* U4DEditor_hpp */
