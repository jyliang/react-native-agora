//
//  RCTAgoraVolumeIndicatorViewManager.m
//  RCTAgora
//
//  Created by Jason Liang on 9/8/18.
//

#import "RCTAgoraVolumeIndicatorViewManager.h"
#import "RCTAgoraVolumeIndicatorView.h"

@implementation RCTAgoraVolumeIndicatorViewManager

RCT_EXPORT_MODULE()

RCT_EXPORT_VIEW_PROPERTY(remoteId, NSInteger)

- (UIView *)view {
  return [[RCTAgoraVolumeIndicatorView alloc] init];
}

@end
