//
//  AgoraStateManager.m
//  RCTAgora
//
//  Created by Jason Liang on 9/14/18.
//  Copyright © 2018 Syan. All rights reserved.
//

#import "AgoraStateManager.h"
#import <React/RCTEventDispatcher.h>
#import "RCTAgoraVideoView.h"

@interface BunchDelayOperation : NSOperation

@property (nonatomic, readonly) NSTimeInterval delay;


@end

@implementation BunchDelayOperation

- (instancetype)initWithDelay:(NSTimeInterval)delay {
  self = [super init];
  if (self) {
    _delay = delay;
  }
  return self;
}

- (void)main {
  NSTimeInterval interval = 0.2;
  while (_delay > 0) {
    if (self.isCancelled) {
      return;
    }
    [NSThread sleepForTimeInterval:interval];
    _delay = _delay - interval;
  }
}

@end

@interface AgoraStateManager()
@property (nonatomic, strong) NSMutableDictionary *videoStateMap;
@property (nonatomic, strong) NSMutableSet *uidIgnoreSet;
@property (nonatomic, strong) NSMutableDictionary *operationDelayMap;
@property (nonatomic, strong) NSMutableDictionary *operationMap;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *videoRateMap;
@property (nonatomic, strong) NSMutableDictionary *videoViewMap;
@property (nonatomic, strong) NSMutableDictionary *memberInfoMap;
@property (nonatomic, strong) NSMutableDictionary *memberUserIdStreamIdMap;

@end

@implementation AgoraStateManager


+ (AgoraStateManager *)sharedInstance {
  static AgoraStateManager *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[AgoraStateManager alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.videoStateMap = [NSMutableDictionary new];
    self.uidIgnoreSet = [NSMutableSet new];
    self.queue = [[NSOperationQueue alloc] init];
    self.operationDelayMap = [NSMutableDictionary new];
    self.operationMap = [NSMutableDictionary new];
    self.videoRateMap = [NSMutableDictionary new];
    self.videoViewMap = [NSMutableDictionary new];
    self.memberInfoMap = [NSMutableDictionary new];
    self.memberUserIdStreamIdMap = [NSMutableDictionary new];
  }
  return self;
}

- (void)registerVideoView:(RCTAgoraVideoView *)view forUserID:(NSInteger)uid {
  NSNumber *key = [NSNumber numberWithInteger:uid];
  self.videoViewMap[key] = view;
}

- (void)unregsiterVideoView:(NSInteger)uid {
  NSNumber *key = [NSNumber numberWithInteger:uid];
  [self.videoViewMap removeObjectForKey:key];
}

- (AgoraVideoRemoteState)getCorrectedStateForUID:(NSUInteger)uid withNewState:(AgoraVideoRemoteState)newState {
  NSNumber *key = [NSNumber numberWithUnsignedInteger:uid];
  if (self.videoStateMap[key] && [self.uidIgnoreSet containsObject:key]) {
    [self.uidIgnoreSet removeObject:key];
    return (AgoraVideoRemoteState)[self.videoStateMap[key] unsignedIntegerValue];
  }
  self.videoStateMap[key] = [NSNumber numberWithUnsignedInteger:(NSUInteger)newState];
  return newState;
}

- (void)tryIgnoreNextStateUpdateForUID:(NSUInteger)uid {
  NSNumber *key = [NSNumber numberWithUnsignedInteger:uid];
  if (self.videoStateMap[key]) {
    [self.uidIgnoreSet addObject:key];
  }
}

- (void)removeStateCheckForUID:(NSUInteger)uid {
  NSNumber *key = [NSNumber numberWithUnsignedInteger:uid];
  [self.videoStateMap removeObjectForKey:key];
  [self.uidIgnoreSet removeObject:key];
}

- (void)remoteVideoStateChangedOfUid:(NSUInteger)uid state:(AgoraVideoRemoteState)state callBackBridge:(RCTBridge *)bridge {
  
  NSNumber *key = [NSNumber numberWithUnsignedInteger:uid];
  NSBlockOperation *op = self.operationMap[key];
  BunchDelayOperation *delayOp = self.operationDelayMap[key];
  [op cancel];
  [delayOp cancel];
  
  op = [NSBlockOperation blockOperationWithBlock:^{
    AgoraVideoRemoteState correctedState = [[AgoraStateManager sharedInstance] getCorrectedStateForUID:uid withNewState:state];
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"type"] = @"onRemoteVideoStateChanged";
    params[@"uid"] = [NSNumber numberWithInteger:uid];
    params[@"state"] = [NSNumber numberWithInteger:(NSInteger)correctedState];
    [bridge.eventDispatcher sendDeviceEventWithName:@"agoraEvent" body:params];
  }];
  [op setCompletionBlock:^{
    [self.operationMap removeObjectForKey:key];
  }];
  self.operationMap[key] = op;
  
  if (state == AgoraVideoRemoteStateFrozen) {
    delayOp = [[BunchDelayOperation alloc] initWithDelay:4];
    [delayOp setCompletionBlock:^{
      [self.operationDelayMap removeObjectForKey:key];
    }];
    [op addDependency:delayOp];
    self.operationDelayMap[key] = delayOp;
    [self.queue addOperations:@[delayOp, op] waitUntilFinished:NO];
  } else {
    [self.queue addOperations:@[op] waitUntilFinished:NO];
  }
}

- (void)processLocalVideoStats:(AgoraRtcLocalVideoStats *)stats callBackBridge:(RCTBridge *)bridge {
  if (!self.onFirstLocalVideoDecoded) {
    if (stats.sentFrameRate > 0) {
      NSMutableDictionary *params = @{}.mutableCopy;
      params[@"type"] = @"onFirstLocalVideoDecoded";
      [bridge.eventDispatcher sendDeviceEventWithName:@"agoraEvent" body:params];
      self.onFirstLocalVideoDecoded = YES;
    }
  }
}

- (void)processRemoteVideoStats:(AgoraRtcRemoteVideoStats *)stats callBackBridge:(RCTBridge *)bridge{
  NSNumber *key = [NSNumber numberWithUnsignedInteger:stats.uid];
  
  if (self.operationMap[key]) {
    //Our default process is making some changes to the states. Relax.
    return;
  }
  NSNumber *storedState = self.videoStateMap[key];
  if (storedState) {
    AgoraVideoRemoteState state = (AgoraVideoRemoteState)[storedState unsignedIntegerValue];
    AgoraVideoRemoteState derivedState = stats.receivedFrameRate > 0 ? AgoraVideoRemoteStateRunning : AgoraVideoRemoteStateFrozen;
    
    if (state != derivedState) {
      [self resetFrozenCounter:stats.uid];
      [self remoteVideoStateChangedOfUid:stats.uid state:derivedState callBackBridge:bridge];
    } else if (derivedState == AgoraVideoRemoteStateFrozen) {
      if ([self shouldTryToFixStream:stats.uid]) {
        if ([self getCounterForUID:stats.uid] == 0) {
          [self attemptToFixFrozenStream:stats.uid];
        }
        [self incrementFrozenCounter:stats.uid];
        if ([self getCounterForUID:stats.uid] == 10) {
          [self resetFrozenCounter:stats.uid];
        }
      }
    } else {
      [self resetFrozenCounter:stats.uid];
    }
  }
}

// Counter 0 means time to fix
- (NSUInteger)getCounterForUID:(NSUInteger)uid {
  NSNumber *key = [NSNumber numberWithUnsignedInteger:uid];
  NSNumber *count = self.videoRateMap[key];
  return [count unsignedIntegerValue];
}

- (NSNumber *)incrementFrozenCounter:(NSUInteger)uid {
  NSNumber *key = [NSNumber numberWithUnsignedInteger:uid];
  NSNumber *count = self.videoRateMap[key];
  if (!count) {
    count = [NSNumber numberWithUnsignedInteger:0];
  }
  count = [NSNumber numberWithUnsignedInteger:count.unsignedIntegerValue + 1];
  self.videoRateMap[key] = count;
  return count;
}

- (void)resetFrozenCounter:(NSUInteger)uid {
  [self.videoRateMap removeObjectForKey:[NSNumber numberWithUnsignedInteger:uid]];
}

- (void)attemptToFixFrozenStream:(NSUInteger)uid {
  NSNumber *key = [NSNumber numberWithUnsignedInteger:uid];
  RCTAgoraVideoView *view = self.videoViewMap[key];
  [view rebootView];
}

- (BOOL)shouldTryToFixStream:(NSUInteger)uid {
  NSString *key = self.memberUserIdStreamIdMap[[NSNumber numberWithUnsignedInteger:uid]];
  NSDictionary *member = self.memberInfoMap[key];
  BOOL shouldFix = NO;
  if (member) {
    // Verify the member has no app state or is in foreground
    NSString *state = member[@"state"];
    shouldFix = state == nil || [state isEqualToString:@"active"];
    // Verify the member has video turned on
    shouldFix = shouldFix && [member[@"publishingVideo"] boolValue];
  }
  return shouldFix;
}

- (void)registerMemberInfo:(NSDictionary *)info {
  NSString *key = info[@"userId"];
  NSNumber *streamId = info[@"streamId"];
  if (key && streamId) {
    self.memberInfoMap[key] = info;
    self.memberUserIdStreamIdMap[streamId] = key;
  }
}

- (void)unregisterMemberInfo:(NSString *)userId {
  if (userId) {
    [self.memberInfoMap removeObjectForKey:userId];
  }
}

- (void)unregisterAllMemberInfo {
  [self.memberInfoMap removeAllObjects];
  [self.memberUserIdStreamIdMap removeAllObjects];
}

@end
