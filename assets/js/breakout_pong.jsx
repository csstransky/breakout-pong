import React from 'react';
import ReactDOM from 'react-dom';
import _ from "lodash";

export default function breakout_pong_init(root, channel) {
    ReactDOM.render(<BreakoutPong channel={channel} />, root);
}

// Client-Side state for BreakoutPong is:
// {
//    TODO: add some documentation
// }
class BreakoutPong extends React.Component {
    constructor(props) {
        super(props);

        this.channel = props.channel;
        this.state = {
            ballx: 100,
            bally: 100,
            ballSpeed: 2,
            velx: 1,
            vely: 1,
            player1x: 670,
            player1y: 100,
            player2x: 10,
            player2y: 100,
            player1score: 0,
            player2score: 0,
            height: 600,
            width: 700,
            upArrow: 38,
            downArrow: 40,
            paddleHeight: 100,
            paddleWidth: 20,
            paddleSpeed: 5,
            ballSize: 10,
            loop: false,
        };

        this.channel
            .join()
            .receive("ok", this.got_view.bind(this))
            .receive("error", resp => { console.log("Unable to join", resp); });
    }


    got_view(view) {
        console.log("new view", view);
        this.setState(view.game);
    }

    initialize_game() {
        this.channel.push("restart")
            .receive("ok", this.got_view.bind(this))
    }

    render() {

        let canvas = document.createElement('CANVAS');
        canvas.height = 150;
        canvas.width = 170;

        let player1 = canvas.getContext("2d");
        player1.fillStyle = '#FF0000';
        player1.fillRect(10, 10, 20, 100);


        return (
            <div dangerouslySetInnerHTML={{ __html: canvas.outerHTML}}/>
              )

    }

}

