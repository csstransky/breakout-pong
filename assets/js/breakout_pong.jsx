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

<<<<<<< HEAD
    this.channel
        .join()
        .receive("ok", this.got_view.bind(this))
        .receive("error", resp => { console.log("Unable to join", resp); });

    this.channel.on("update", resp => {
      console.log(resp)
      this.setState(resp)
    });
  }
=======
        this.channel
            .join()
            .receive("ok", this.got_view.bind(this))
            .receive("error", resp => { console.log("Unable to join", resp); });
    }
>>>>>>> e2676a1847ed40a7f0b3b6edee92101285b580e3


    got_view(view) {
        console.log("new view", view);
        this.setState(view.game);
    }

    initialize_game() {
        this.channel.push("restart")
            .receive("ok", this.got_view.bind(this))
    }

    render() {

<<<<<<< HEAD
  render() {
    if (this.state.isLobby) {
      return (
        <div className="row">
          <div className="column">
            <p>Players:</p>
            <div id="playerList">
              <LobbyList lobbyList={this.state.lobbyList} />
            </div>
          </div>
        </div>
      );
    }
    else {
      return (
        <div>
          <div className="row">
            <div className="column">
              <Word skeleton={this.state.skel} />
            </div>
            <div className="column">
              <Lives lives={this.lives_left()} max={this.state.lives} />
            </div>
          </div>
          <div className="row">
            <div className="column">
              <Guesses guesses={this.state.bads} />
            </div>
            <div className="column">
              <GuessInput guesses={this.guesses()}
                          on_guess={this.on_guess.bind(this)} />
            </div>
          </div>
        </div>
      );
    }
  }
}

function LobbyList({lobbyList}) {
  return _.map(lobbyList, (player, rowNum) => {
    return <div className="row" key={rowNum}>
      <p>{player}</p>
    </div>;
  });
}

function Word(params) {
  let {skeleton} = params;
  return (
    <div>
      <p><b>The Word</b></p>
      <p>{skeleton.join(" ")}</p>
    </div>
  );
}
=======
        let canvas = document.createElement('CANVAS');
        canvas.height = 150;
        canvas.width = 170;

        let player1 = canvas.getContext("2d");
        player1.fillStyle = '#FF0000';
        player1.fillRect(10, 10, 20, 100);

>>>>>>> e2676a1847ed40a7f0b3b6edee92101285b580e3

        return (
            <div dangerouslySetInnerHTML={{ __html: canvas.outerHTML}}/>
              )

    }

}

