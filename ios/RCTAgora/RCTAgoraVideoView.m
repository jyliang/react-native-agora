//
//  RCTAgoraVideoView.m
//  RCTAgora
//
//  Created by 邓博 on 2017/6/30.
//  Copyright © 2017年 Syan. All rights reserved.
//

#import "RCTAgoraVideoView.h"
#import "AgoraStateManager.h"

@implementation RCTAgoraVideoView

- (instancetype)init{
  
  if (self == [super init]) {
    _rtcEngine = [AgoraConst share].rtcEngine;
  }
  
  return self;
}

- (void)setShowLocalVideo:(BOOL)showLocalVideo {
  if (showLocalVideo) {
    _remoteUid = 0;
    AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
    //        canvas.uid = [AgoraConst share].localUid;
    canvas.view = self;
    canvas.renderMode = AgoraVideoRenderModeHidden;
    [_rtcEngine setupLocalVideo:canvas];
  }
}

-(void)setRemoteUid:(NSInteger)remoteUid {
  [[AgoraStateManager sharedInstance] unregsiterVideoView:_remoteUid];
  _remoteUid = remoteUid;
  if (remoteUid > 0) {
    [[AgoraStateManager sharedInstance] tryIgnoreNextStateUpdateForUID:(NSUInteger)remoteUid];
    AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
    canvas.uid = remoteUid;
    canvas.view = self;
    canvas.renderMode = AgoraVideoRenderModeHidden;
    [_rtcEngine setupRemoteVideo:canvas];
    [[AgoraStateManager sharedInstance] registerVideoView:self forUserID:remoteUid];
  }
}

- (void)rebootView {
  [self setRemoteUid:_remoteUid];
}

@end
