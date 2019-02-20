import React from 'react';
import ReactDOM from 'react-dom';
import _ from "lodash";

export default function breakout_pong_init(root, channel) {
    ReactDOM.render(<BreakoutPong channel={channel} />, root);
  ReactDOM.render(<BreakoutPong channel={channel}/>, root);
}

// Global used for the movement of the paddle
var PADDLE_MOVE = 40;

// Client-Side state for BreakoutPong is:
// {
//    TODO: add some documentation
// }
class BreakoutPong extends React.Component {
  constructor(props) {
    super(props);

    this.channel = props.channel;
    // I took most variables out of here so we can minimize the data being transported in state changes
    // We can probably add back "window size" and stuff as global, but local variables if we want
    this.state = {
      isLobby: false,
      lobbyList: [],
      player1: "",
      player2: "",
      ballx: 100,
      bally: 100,
      player1x: 10,
      player1y: 0,
      player2x: 770,
      player2y: 0,
      player1score: 0,
      player2score: 0,
      windowHeight: 600,
      windowWidth: 800,
    };

    this.channel
      .join()
      .receive("ok", this.got_view.bind(this))
      .receive("error", resp => {
        console.log("Unable to join", resp);
      });

    this.channel.on("update", resp => {
      console.log(resp)
      this.setState(resp)
    });
  }

  componentDidMount() {
    this.draw_canvas();
    this.interval = setInterval(() => this.setState(this.draw_canvas()), 50);
  }

  componentWillUnmount() {
    clearInterval(this.interval);
  }

  // TODO: There's probably an issue with the got-view function not being called to update the world
  got_view(view) {
    console.log("new view");
    this.setState(view.game);
  }

  initialize_game() {
    console.log("game restarted from browser side");
    this.channel.push("restart")
      .receive("ok", this.got_view.bind(this))
  }

  startGame() {
    this.channel.push("start_game")
      .receive("ok", resp => {
        console.log("Game has started", resp.game)
        this.setState(resp.game);
      });
  }

  draw_canvas() {
    console.log("redrawing canvas")
    let canvas = this.refs.canvas;

    let ctx = canvas.getContext("2d");

    // Player Graphics
    ctx.fillStyle = "#002eff";
    ctx.setLineDash([]);
    ctx.clearRect(0, 0, this.state.windowWidth, this.state.windowHeight);
    ctx.strokeRect(0,0, this.state.windowWidth, this.state.windowHeight);
    ctx.fillRect(this.state.player2x, this.state.player2y, 20, 110);
    ctx.fillRect(this.state.player1x, this.state.player1y, 20, 110);
    ctx.font = "20px Courier"
    ctx.fillText(this.state.player1, 100, 20);
    ctx.fillText(this.state.player2, 500, 20);
    ctx.font = "40px Comic Sans"
    ctx.fillText(this.state.player1score, 350, 40);
    ctx.fillText(this.state.player2score, 430, 40);
    ctx.setLineDash([2,4]);
    ctx.beginPath();
    ctx.moveTo(20, 0);
    ctx.lineTo(20, 600)
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(780, 0);
    ctx.lineTo(780, 600)
    ctx.stroke();
    ctx.setLineDash([4,8]);
    ctx.beginPath();
    ctx.moveTo(400, 0);
    ctx.lineTo(400, 600)
    ctx.stroke();


    // Ball Graphics
    ctx.fillStyle = "#06ff18";
    ctx.beginPath();
    ctx.arc(50, 50, 8, 0, 2 * Math.PI);
    ctx.fill();


    return canvas;
  }

  on_key(ev) {
    console.log(ev.which);
    if (ev.which == 38 || ev.which == 37) { //this is the up arrow
      // this.channel.push("onkey", {keypressed: "up"})
      //     .receive("ok", this.got_view.bind(this));
      this.channel.push("move_paddle", {paddle_move_dist: -1 * PADDLE_MOVE})
        .receive("ok", this.got_view.bind(this));
      this.draw_canvas();
    }
    if (ev.which == 40 || ev.which == 39) { //this is the down arrow
      this.channel.push("move_paddle", {paddle_move_dist: PADDLE_MOVE})
        .receive("ok", this.got_view.bind(this));
      this.draw_canvas();
    } else {
      console.log("Key Pressed: Not an up or down key.")
      console.log(ev.which);
    }
  }

  render() {
    if (this.state.isLobby) {
      return (
        <div className="row">
          <div className="column">
            <p>Players:</p>
            <div id="playerList">
              <LobbyList lobbyList={this.state.lobbyList}/>
              <button onClick={this.startGame.bind(this)}>Start Game</button>
            </div>
          </div>
        </div>
      );
    } else {
      return (
        <div>
          <input type="text" id="one" onKeyDown={this.on_key.bind(this)}/>
          <canvas ref="canvas" width={800} height={600}/>
        </div>
      )
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
