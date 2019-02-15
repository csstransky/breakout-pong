import React from 'react';
import ReactDOM from 'react-dom';
import _ from "lodash";

export default function lobby_init(root, channel) {
    ReactDOM.render(<Lobby channel={channel} />, root);
}

class Lobby extends React.Component {
    constructor(props) {
        super(props);

        this.channel = props.channel;
        this.state = {
            players: ["testing user"]
        };

        this.channel
            .join()
            .receive("ok", this.got_view.bind(this))
            .receive("error", resp => {
                console.log("Unable to join", resp);
            });
    }

    render() {
        return (
            <div>
                this.state.players.toString();
            </div>
        );
    }
}