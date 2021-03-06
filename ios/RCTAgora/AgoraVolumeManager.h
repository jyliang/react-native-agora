//
//  AgoraVolumeManager.h
//  RCTAgora
//
//  Created by Jason Liang on 9/8/18.
//

#import <Foundation/Foundation.h>
#import "RCTAgoraVolumeIndicatorView.h"
#import "AgoraConst.h"

@interface AgoraVolumeManager : NSObject

+ (AgoraVolumeManager *)sharedInstance;

- (void)registerView:(id<RCTAgoraVolumeIndicatorDelegate>)view withRemoteId:(NSInteger)remoteId;
- (void)unregisterView:(id<RCTAgoraVolumeIndicatorDelegate>)view withRemoteId:(NSInteger)remoteId;
- (void)updateRemoteId:(NSUInteger)remoteId withVolume:(NSUInteger)volume;

@end
