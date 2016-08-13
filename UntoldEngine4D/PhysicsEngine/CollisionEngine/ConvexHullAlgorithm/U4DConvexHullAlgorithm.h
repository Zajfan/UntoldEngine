//
//  U4DConvexHullAlgorithm.hpp
//  UntoldEngine
//
//  Created by Harold Serrano on 8/11/16.
//  Copyright © 2016 Untold Game Studio. All rights reserved.
//
//  This is a C++ implementation of Joseph O'Rourke's classic Incremental Convex Hull
//  algorithm mentioned in his book "Computation Geometry" 2nd edition.
//  In contrast to his original implementation this implementation works with floating point numbers.
//  The algorithm has been minimally modified to work with the Untold Engine by Harold Serrano

#ifndef U4DConvexHullAlgorithm_hpp
#define U4DConvexHullAlgorithm_hpp

#include <stdio.h>
#include "CommonProtocols.h"
#include "U4DVector3n.h"

namespace U4DEngine {
    
    class U4DConvexHullAlgorithm{
        
    private:
        CONVEXHULLVERTEX vertexHead;
        CONVEXHULLEDGE edgeHead;
        CONVEXHULLFACE faceHead;
        
    public:
        U4DConvexHullAlgorithm();
        ~U4DConvexHullAlgorithm();
        
        CONVEXHULLVERTEX makeNullVertex();
        CONVEXHULLEDGE makeNullEdge();
        CONVEXHULLFACE makeNullFace();
        
        CONVEXHULL computeConvexHull(std::vector<U4DVector3n> &uVertices);
        void readVertices(std::vector<U4DVector3n> &uVertices);
        bool doubleTriangle();
        bool collinear(CONVEXHULLVERTEX a, CONVEXHULLVERTEX b, CONVEXHULLVERTEX c);
        CONVEXHULLFACE makeFace(CONVEXHULLVERTEX v0, CONVEXHULLVERTEX v1, CONVEXHULLVERTEX v2, CONVEXHULLFACE fold);
        bool constructHull();
        bool addOne(CONVEXHULLVERTEX p);
        int volumeSign(CONVEXHULLFACE f, CONVEXHULLVERTEX p);
        CONVEXHULLFACE makeConeFace(CONVEXHULLEDGE e, CONVEXHULLVERTEX p);
        void makeCcw(CONVEXHULLFACE f,CONVEXHULLEDGE e,CONVEXHULLVERTEX p);
        void swapEdges(CONVEXHULLEDGE t, CONVEXHULLEDGE x, CONVEXHULLEDGE y);
        void cleanUp(CONVEXHULLVERTEX *pvnext);
        void cleanEdges();
        void cleanFaces();
        void cleanVertices(CONVEXHULLVERTEX *pvnext);
        void deleteEdge(CONVEXHULLEDGE p);
        void deleteFace(CONVEXHULLFACE p);
        void deleteVertex(CONVEXHULLVERTEX p);
        
        bool checkIfConvexHullIsValid();
        bool checkIfConsistencyPassed();
        bool checkIfConvexityPassed();
        bool checkIfEulerFormulaPassed();
        
        void loadComputedCHVertices(CONVEXHULL &uConvexHull);
        void loadComputedCHEdges(CONVEXHULL &uConvexHull);
        void loadComputedCHFaces(CONVEXHULL &uConvexHull);
    };
}

#endif /* U4DConvexHullAlgorithm_hpp */