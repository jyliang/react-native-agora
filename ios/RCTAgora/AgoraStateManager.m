//
//  AgoraStateManager.m
//  RCTAgora
//
//  Created by Jason Liang on 9/14/18.
//  Copyright © 2018 Syan. All rights reserved.
//

#import "AgoraStateManager.h"

@interface AgoraStateManager()
@property (nonatomic, strong) NSMutableDictionary *videoStateMap;
@property (nonatomic, strong) NSMutableSet *uidIgnoreSet;
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


@end
