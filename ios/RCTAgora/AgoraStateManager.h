//
//  AgoraStateManager.h
//  RCTAgora
//
//  Created by Jason Liang on 9/14/18.
//  Copyright © 2018 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridge.h>
#import "AgoraConst.h"

// This entire class is to amend a sideeffect:
/*
 1. A and B is in a chat
 2. A enters background, state is Frozen
 3. B observes the Frozen state and makes the correct change
 4. B navigates to a different screen, the state of A is re-render and returns 'Running' which is WRONG.
 
 Solution: ignore first signal after re-render if the state was registered for that remote id before
 */

@interface AgoraStateManager : NSObject

+ (AgoraStateManager *)sharedInstance;

- (AgoraVideoRemoteState)getCorrectedStateForUID:(NSUInteger)uid withNewState:(AgoraVideoRemoteState)newState;
- (void)tryIgnoreNextStateUpdateForUID:(NSUInteger)uid;
- (void)removeStateCheckForUID:(NSUInteger)uid;
- (void)remoteVideoStateChangedOfUid:(NSUInteger)uid state:(AgoraVideoRemoteState)state callBackBridge:(RCTBridge *)bridge;

@end
