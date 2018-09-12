//
//  AgoraVolumeManager.m
//  RCTAgora
//
//  Created by Jason Liang on 9/8/18.
//

#import "AgoraVolumeManager.h"

@interface AgoraVolumeManager()
@property (nonatomic, strong) NSMutableDictionary *remoteViewMap; //keyed by remoteId
@end

@implementation AgoraVolumeManager

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static AgoraVolumeManager *_instance;
  dispatch_once(&onceToken, ^{
    _instance = [[AgoraVolumeManager alloc] init];
  });
  return _instance;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.remoteViewMap = [NSMutableDictionary new];
  }
  return self;
}


- (NSMutableSet *)viewArrayForRemoteId:(NSUInteger)remoteId {
  NSNumber *key = [NSNumber numberWithUnsignedInteger:remoteId];
  NSMutableSet *va = self.remoteViewMap[key];
  if (!va) {
    va = [NSMutableSet new];
    self.remoteViewMap[key] = va;
  }
  return va;
}

- (void)registerView:(id<RCTAgoraVolumeIndicatorDelegate>)view withRemoteId:(NSInteger)remoteId {
  NSMutableSet *va = [self viewArrayForRemoteId:remoteId];
  [va addObject:view];
}


- (void)unregisterView:(id<RCTAgoraVolumeIndicatorDelegate>)view withRemoteId:(NSInteger)remoteId {
  NSMutableSet *va = [self viewArrayForRemoteId:remoteId];
  [va removeObject:view];
}

- (void)updateRemoteId:(NSUInteger)remoteId withVolume:(NSUInteger)volume {
  NSMutableSet *va = [self viewArrayForRemoteId:remoteId];
  CGFloat percent = ((CGFloat)volume / 100.0 * 100);
  for (id<RCTAgoraVolumeIndicatorDelegate> v in [va allObjects]) {
    [v updateVolumePercent:percent];
  }
}
@end
