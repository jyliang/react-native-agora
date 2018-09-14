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

- (instancetype)init {
  self = [super init];
  if (self) {
    self.remoteViewMap = [NSMutableDictionary new];
  }
  return self;
}

- (NSPointerArray *)viewArrayForRemoteId:(NSUInteger)remoteId {
  NSNumber *key = [NSNumber numberWithUnsignedInteger:remoteId];
  NSPointerArray *va = self.remoteViewMap[key];
  if (!va) {
    va = [NSPointerArray weakObjectsPointerArray];
    self.remoteViewMap[key] = va;
  }
  return va;
}

- (void)registerView:(id<RCTAgoraVolumeIndicatorDelegate>)view withRemoteId:(NSInteger)remoteId {
  NSPointerArray *va = [self viewArrayForRemoteId:remoteId];
  [va addPointer:(__bridge void * _Nullable)(view)];
  NSInteger foundIndex = NSNotFound;
  NSUInteger index = 0;
  for (id<RCTAgoraVolumeIndicatorDelegate> v in va) {
    if (v == view) {
      foundIndex = index;
      break;
    }
    index++;
  }
}

- (void)unregisterView:(id<RCTAgoraVolumeIndicatorDelegate>)view withRemoteId:(NSInteger)remoteId {
  NSPointerArray *va = [self viewArrayForRemoteId:remoteId];
  NSMutableArray *indexes = [NSMutableArray new];
  NSUInteger index = 0;
  for (id<RCTAgoraVolumeIndicatorDelegate> v in va) {
    if (!v || v == view) {
      [indexes addObject:[NSNumber numberWithUnsignedInteger:index]];
    }
    index++;
  }
  for (int i = (int)indexes.count-1; i >= 0; i--) {
    [va removePointerAtIndex:[indexes[i] unsignedIntegerValue]];
  }
  if (va.count == 0) {
    [self.remoteViewMap removeObjectForKey:[NSNumber numberWithInteger:remoteId]];
  }
}

- (void)updateRemoteId:(NSUInteger)remoteId withVolume:(NSUInteger)volume {
  NSPointerArray *va = [self viewArrayForRemoteId:remoteId];
  CGFloat percent = ((CGFloat)volume / 100.0 * 100);
  for (id<RCTAgoraVolumeIndicatorDelegate> v in va) {
    [v updateVolumePercent:percent];
  }
}

@end
