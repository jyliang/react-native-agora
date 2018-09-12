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
RCT_EXPORT_VIEW_PROPERTY(minPercent, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(isCircle, BOOL)

- (UIView *)view {
  return [[RCTAgoraVolumeIndicatorView alloc] init];
}

@end
