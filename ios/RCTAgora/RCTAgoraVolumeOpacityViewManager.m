//
//  RCTAgoraVolumeOpacityViewManager.m
//  RCTAgora
//
//  Created by Jason Liang on 9/11/18.
//

#import "RCTAgoraVolumeOpacityViewManager.h"
#import "RCTAgoraVolumeOpacityView.h"

@implementation RCTAgoraVolumeOpacityViewManager

RCT_EXPORT_MODULE()

RCT_EXPORT_VIEW_PROPERTY(remoteId, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(minOpacity, CGFloat)

- (UIView *)view {
  return [[RCTAgoraVolumeOpacityView alloc] init];
}

@end
