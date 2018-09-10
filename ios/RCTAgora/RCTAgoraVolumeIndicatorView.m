//
//  RCTAgoraVolumeIndicatorView.m
//  RCTAgora
//
//  Created by Jason Liang on 9/8/18.
//

#import "RCTAgoraVolumeIndicatorView.h"
#import "AgoraVolumeManager.h"
#import "CircleView.h"

@interface RCTAgoraVolumeIndicatorView()

@property (nonatomic, strong) UIView *circleView;

@end

@implementation RCTAgoraVolumeIndicatorView

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.circleView = [[CircleView alloc] init];
    self.circleView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.circleView];
  }
  return self;
}

- (void)setPercent:(CGFloat)percent {
  _percent = MIN(100, percent);
  
  CGFloat minPercent = 0.2;
  CGFloat minDimension = MIN(self.bounds.size.width, self.bounds.size.height);
  CGFloat insetDistance =  (1 - (_percent/100 * (1 - minPercent) + minPercent)) *  minDimension / 2;
  CGFloat length = minDimension - insetDistance * 2;
  CGRect borderRect = CGRectMake((self.bounds.size.width - length) /2 ,
                                 (self.bounds.size.height - length) / 2,
                                 length,
                                 length);
  
  [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
    self.circleView.frame = borderRect;
    [self.circleView setNeedsDisplay];
  } completion:nil];
}

- (void)setRemoteId:(NSUInteger)remoteId {
  [AgoraVolumeManager.sharedInstance unregisterView:self withRemoteId:_remoteId];
  _remoteId = remoteId;
  [AgoraVolumeManager.sharedInstance registerView:self withRemoteId:remoteId];
}

- (void)dealloc {
  [AgoraVolumeManager.sharedInstance unregisterView:self withRemoteId:_remoteId];
}

@end
