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

@class RCTAgoraVideoView;
// This entire class is to amend a sideeffect:
/*
 1. A and B is in a chat
 2. A enters background, state is Frozen
 3. B observes the Frozen state and makes the correct change
 4. B navigates to a different screen, the state of A is re-render and returns 'Running' which is WRONG.
 
 Solution: ignore first signal after re-render if the state was registered for that remote id before
 */

/*
 This class is now more powerful to counter freeze flickering by using operation queues to delay the effect for a few seconds before switching to video placeholder.
 
 This class is now handling video state correction (derived from video frame rate) to improve QOS.
 */

@interface AgoraStateManager : NSObject

+ (AgoraStateManager *)sharedInstance;

@property (strong, nonatomic) AgoraRtcEngineKit *rtcEngine;

@property (nonatomic, strong) NSString *channelName;
@property (nonatomic) NSInteger uid;
@property (nonatomic) BOOL onFirstLocalVideoDecoded;

- (void)registerVideoView:(RCTAgoraVideoView *)view forUserID:(NSInteger)uid;
- (void)unregsiterVideoView:(NSInteger)uid;

- (AgoraVideoRemoteState)getCorrectedStateForUID:(NSUInteger)uid withNewState:(AgoraVideoRemoteState)newState;
- (void)tryIgnoreNextStateUpdateForUID:(NSUInteger)uid;
- (void)removeStateCheckForUID:(NSUInteger)uid;
- (void)remoteVideoStateChangedOfUid:(NSUInteger)uid state:(AgoraVideoRemoteState)state callBackBridge:(RCTBridge *)bridge;
- (void)processLocalVideoStats:(AgoraRtcLocalVideoStats *)stats callBackBridge:(RCTBridge *)bridge;
- (void)processRemoteVideoStats:(AgoraRtcRemoteVideoStats *)stats callBackBridge:(RCTBridge *)bridge;

// These member infos are useful when retry to fix user video states.
- (void)registerMemberInfo:(NSDictionary *)info;
- (void)unregisterMemberInfo:(NSString *)userId;
- (void)unregisterAllMemberInfo;

@end
