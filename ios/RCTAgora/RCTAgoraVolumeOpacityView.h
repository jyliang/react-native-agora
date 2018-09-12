//
//  RCTAgoraVolumeOpacityView.h
//  RCTAgora
//
//  Created by Jason Liang on 9/11/18.
//

#import <UIKit/UIKit.h>
#import "AgoraConst.h"

@interface RCTAgoraVolumeOpacityView : UIView <RCTAgoraVolumeIndicatorDelegate>

@property (nonatomic) NSUInteger remoteId;
@property (nonatomic) CGFloat minOpacity;

@end
