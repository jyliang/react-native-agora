import  React, {Component} from 'react'
import {PropTypes} from 'prop-types'
import {
    requireNativeComponent,
    View,
    Platform
} from 'react-native'

export default class AgoraVolumeIndicatorView extends Component {

    render() {
        return (
            <RCTAgoraVolumeIndicatorView {...this.props}/>
        )
    }
}

AgoraVolumeIndicatorView.propTypes = {
    remoteId: PropTypes.number,
    minPercent: PropTypes.number,
    isCircle: PropTypes.bool,
    ...View.propTypes
};

const RCTAgoraVolumeIndicatorView = requireNativeComponent("RCTAgoraVolumeIndicatorView", AgoraVolumeIndicatorView);
