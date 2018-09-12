//
//  RCTAgoraVolumeOpacityView.m
//  RCTAgora
//
//  Created by Jason Liang on 9/11/18.
//

#import "RCTAgoraVolumeOpacityView.h"
#import "AgoraVolumeManager.h"

@implementation RCTAgoraVolumeOpacityView

- (void)setRemoteId:(NSUInteger)remoteId {
  [AgoraVolumeManager.sharedInstance unregisterView:self withRemoteId:_remoteId];
  _remoteId = remoteId;
  [AgoraVolumeManager.sharedInstance registerView:self withRemoteId:remoteId];
}

- (void)dealloc {
  [AgoraVolumeManager.sharedInstance unregisterView:self withRemoteId:_remoteId];
}

#pragma mark - RCTAgoraVolumeIndicatorDelegate
- (void)updateVolumePercent:(CGFloat)percent {
  
  [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
    self.alpha = MIN(percent / 100.0, 1) * (1 - self.minOpacity) + self.minOpacity;
  } completion:nil];
}

@end
