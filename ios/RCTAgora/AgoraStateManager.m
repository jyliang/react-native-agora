//
//  AgoraStateManager.m
//  RCTAgora
//
//  Created by Jason Liang on 9/14/18.
//  Copyright © 2018 Syan. All rights reserved.
//

#import "AgoraStateManager.h"
#import <React/RCTEventDispatcher.h>

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
  }
  return self;
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

@end
