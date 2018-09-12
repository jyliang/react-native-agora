//
//  RCTAgoraVolumeIndicatorView.h
//  RCTAgora
//
//  Created by Jason Liang on 9/8/18.
//

#import <UIKit/UIKit.h>
#import "AgoraConst.h"

@interface RCTAgoraVolumeIndicatorView : UIView <RCTAgoraVolumeIndicatorDelegate>

@property (nonatomic) CGFloat percent;
@property (nonatomic) NSUInteger remoteId;
@property (nonatomic) CGFloat minPercent;
@property (nonatomic) BOOL isCircle;

@end
