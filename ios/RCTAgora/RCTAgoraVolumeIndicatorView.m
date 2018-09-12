//
//  RCTAgoraVolumeIndicatorView.m
//  RCTAgora
//
//  Created by Jason Liang on 9/8/18.
//

#import "RCTAgoraVolumeIndicatorView.h"
#import "AgoraVolumeManager.h"
#import "IndicatorView.h"

@interface RCTAgoraVolumeIndicatorView()

@property (nonatomic, strong) IndicatorView *indicatorView;
@property (nonatomic) BOOL firstLayout;

@end

@implementation RCTAgoraVolumeIndicatorView

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.indicatorView = [[IndicatorView alloc] init];
    self.indicatorView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.indicatorView];
    self.firstLayout = YES;
    self.minPercent = 50;
  }
  return self;
}

- (void)setIsCircle:(BOOL)isCircle {
  _isCircle = isCircle;
  self.indicatorView.isCircle = isCircle;
  [self update];
}

- (void)setPercent:(CGFloat)percent {
  _percent = MIN(100, percent);
  [self update];
}

- (void)setMinPercent:(CGFloat)minPercent {
  _minPercent = MIN(100, minPercent);
  [self update];
}

- (void)update {
  CGFloat minPercent = self.minPercent / 100.0;
  CGFloat minDimension = MIN(self.bounds.size.width, self.bounds.size.height);
  CGFloat insetDistance =  (1 - (_percent/100 * (1 - minPercent) + minPercent)) *  minDimension / 2;
  CGFloat length = minDimension - insetDistance * 2;
  CGRect borderRect = CGRectMake((self.bounds.size.width - length) /2 ,
                                 (self.bounds.size.height - length) / 2,
                                 length,
                                 length);
  
  if (self.firstLayout) {
    self.indicatorView.frame = borderRect;
    [self.indicatorView setNeedsDisplay];
    self.firstLayout = NO;
    return;
  }
  
  [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
    self.indicatorView.frame = borderRect;
    [self.indicatorView setNeedsDisplay];
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

#pragma mark - RCTAgoraVolumeIndicatorDelegate
- (void)updateVolumePercent:(CGFloat)percent {
  self.percent = percent;
}

@end
