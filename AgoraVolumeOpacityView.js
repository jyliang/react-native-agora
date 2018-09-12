import  React, {Component} from 'react'
import {PropTypes} from 'prop-types'
import {
    requireNativeComponent,
    View,
    Platform
} from 'react-native'

export default class AgoraVolumeOpacityView extends Component {

    render() {
        return (
            <RCTAgoraVolumeOpacityView {...this.props}/>
        )
    }
}

AgoraVolumeOpacityView.propTypes = {
    remoteId: PropTypes.number,
    minOpacity: PropTypes.number,
    ...View.propTypes
};

const RCTAgoraVolumeOpacityView = requireNativeComponent("RCTAgoraVolumeOpacityView", AgoraVolumeOpacityView);
