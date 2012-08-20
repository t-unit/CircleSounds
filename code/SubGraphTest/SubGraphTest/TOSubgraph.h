//
//  TOSubgraph.h
//  SubGraphTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface TOSubgraph : NSObject
{
    //
    // Initial Graph
    // mixer -> rio unit
    
    AUGraph graph;
    
    AudioUnit mixerUnit;
    AUNode mixerNode;
    
    AudioUnit rioUnit;
    AUNode rioNode;
    
    
    //
    // Additional Units
    // file player unit -> varispeed -> generic output -> 
    
    AudioUnit filePlayerUnit;
    AUNode filePlayerNode;
    
    AudioUnit varispeedUnit;
    AUNode varispeedNode;
    
    AudioFileID audioFile;
}

@end
