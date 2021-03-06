import React from 'react';
import ReactDOM from 'react-dom';
import _ from "lodash";

export default function breakout_pong_init(root, channel) {
    ReactDOM.render(<BreakoutPong channel={channel} />, root);
  ReactDOM.render(<BreakoutPong channel={channel}/>, root);
}

// Global used for the movement of the paddle
let PADDLE_MOVE = 80;

// Client-Side state for BreakoutPong is:
class BreakoutPong extends React.Component {
  constructor(props) {
    super(props);

    this.channel = props.channel;
    this.state = {
      isLobby: true,
      lobbyList: ["Loading lobby..."],
      winScore: 50,
      player1: "",
      player2: "",
      ball1x: 100,
      ball1y: 120,
      ball2x: 700,
      ball2y: 120,
      player1x: 10,
      player1y: 5,
      player2x: 770,
      player2y: 5,
      player1score: 0,
      player2score: 0,
      windowHeight: 600,
      windowWidth: 800,
      blocks: [
        {x: 310, y: 1, hp: 1},
        {x: 350, y: 1, hp: 2},
        {x: 390, y: 1, hp: 4},
        {x: 430, y: 1, hp: 2},
        {x: 470, y: 1, hp: 1},
        {x: 310, y: 100, hp: 1},
        {x: 350, y: 100, hp: 2},
        {x: 390, y: 100, hp: 4},
        {x: 430, y: 100, hp: 2},
        {x: 470, y: 100, hp: 1},
        {x: 310, y: 200, hp: 1},
        {x: 350, y: 200, hp: 2},
        {x: 390, y: 200, hp: 4},
        {x: 430, y: 200, hp: 2},
        {x: 470, y: 200, hp: 1},
        {x: 310, y: 300, hp: 1},
        {x: 350, y: 300, hp: 2},
        {x: 390, y: 300, hp: 4},
        {x: 430, y: 300, hp: 2},
        {x: 470, y: 300, hp: 1},
        {x: 310, y: 400, hp: 1},
        {x: 350, y: 400, hp: 2},
        {x: 390, y: 400, hp: 4},
        {x: 430, y: 400, hp: 2},
        {x: 470, y: 400, hp: 1},
        {x: 310, y: 499, hp: 1},
        {x: 350, y: 499, hp: 2},
        {x: 390, y: 499, hp: 4},
        {x: 430, y: 499, hp: 2},
        {x: 470, y: 499, hp: 1}]
    };

    this.channel
      .join()
      .receive("ok", this.got_view.bind(this))
      .receive("error", resp => {
        console.log("Unable to join", resp);
      });

    this.channel.on("update", resp => {
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

  got_view(view) {
    console.log("new view");
    this.setState(view.gameName);
  }

  startGame() {
    if (this.state.lobbyList.length <= 1) {
      alert("You need a friend to play this game!")
    }

    this.channel.push("start_game")
      .receive("ok", resp => {
        console.log("Game has started", resp.game);
        this.setState(resp.game);
      });
  }

  draw_canvas() {
    if (this.state.isLobby) {
      return
    }

    let canvas = this.refs.canvas;
    let ctx = canvas.getContext("2d");
    ctx.fillStyle = "#FFFFFF";
    ctx.strokeStyle = "#000000";
    ctx.clearRect(0, 0, this.state.windowWidth, this.state.windowHeight);
    ctx.strokeRect(0, 0, this.state.windowWidth, this.state.windowHeight);
    ctx.fillRect(0, 0, this.state.windowWidth, this.state.windowHeight);


    // Player Graphics
    ctx.lineWidth = 2;
    ctx.fillStyle = "#ffba31";
    ctx.font = "20px Courier"
    ctx.fillText(this.state.player1, 100, 20);
    ctx.fillText(this.state.player2, 600, 20);
    ctx.font = "40px Comic Sans"
    ctx.fillText(this.state.player1score, 250, 40);
    ctx.fillText(this.state.player2score, 530, 40);
    ctx.setLineDash([2,3]);
    // Player 1 paddle dash line
    ctx.beginPath();
    ctx.moveTo(20, 0);
    ctx.lineTo(20, 600)
    ctx.stroke();
    // Player 2 paddle dash line
    ctx.beginPath();
    ctx.moveTo(780, 0);
    ctx.lineTo(780, 600)
    ctx.stroke();
    // center court
    ctx.setLineDash([1,1]);
    ctx.beginPath();
    ctx.moveTo(400, 0);
    ctx.lineTo(400, 600)
    ctx.stroke();

    // Paddles are drawn below here
    ctx.fillStyle = "#002eff";
    ctx.setLineDash([]);
    ctx.strokeRect(0,0, this.state.windowWidth, this.state.windowHeight);
    ctx.strokeRect(this.state.player2x, this.state.player2y, 20, 110);
    ctx.fillRect(this.state.player2x, this.state.player2y, 20, 110);
    ctx.fillStyle = "#00fff8";
    ctx.strokeRect(this.state.player1x, this.state.player1y, 20, 110);
    ctx.fillRect(this.state.player1x, this.state.player1y, 20, 110);
    ctx.stroke();

    // Blocks rendered down here
    var colors = ["#FFFFFF", "#aaffa3", "#4cd647","#00a608","#00aa0b"]
    var lines = ["#FFFFFF", "#000000", "#000000","#000000","#000000"]
    var index;
    console.log(this.state.blocks);
    ctx.lineWidth = 3;
    for (index = 0; index < this.state.blocks.length; ++index) {
      ctx.fillStyle = colors[this.state.blocks[index].hp];
      ctx.strokeStyle = lines[this.state.blocks[index].hp];
      ctx.strokeRect(this.state.blocks[index].x, this.state.blocks[index].y, 37, 97)
      ctx.fillRect(this.state.blocks[index].x, this.state.blocks[index].y, 37, 97)
    }

    // Ball Graphics
    ctx.lineWidth = 1;
    ctx.strokeStyle = "#000000";
    ctx.fillStyle = "#002eff";
    ctx.beginPath();
    ctx.arc(this.state.ball2x, this.state.ball2y, 8, 0, 2 * Math.PI);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(this.state.ball2x, this.state.ball2y, 8, 0, 2 * Math.PI);
    ctx.stroke();
    ctx.fillStyle = "#00fff8";
    ctx.beginPath();
    ctx.arc(this.state.ball1x, this.state.ball1y, 8, 0, 2 * Math.PI);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(this.state.ball1x, this.state.ball1y, 8, 0, 2 * Math.PI);
    ctx.stroke();
    ctx.lineWidth = 2;

    // Render win screen over game, if score indicates player has won
    if (this.state.player1score >= this.state.winScore || this.state.player2score >= this.state.winScore) {

      // Determine which player won
      var winner;
      var loser;
      if (this.state.player1score >= this.state.winScore) {
        winner = this.state.player1;
        loser = this.state.player2;
      } else {
        winner = this.state.player2;
        loser = this.state.player1;
      }

      // Setup the background for the win screen
      var grd = ctx.createLinearGradient(100, 100, 400, 0);
      grd.addColorStop(0, "red");
      grd.addColorStop(1, "white");
      ctx.strokeRect(100, 100, 600, 400);
      ctx.fillRect(100, 100, 600, 400);

      // Setup the text for win
      ctx.fillStyle = "#4d6eac";
      ctx.font = "40px Courier"
      ctx.fillText(winner + " wins!", 200, 200);
      ctx.font = "30px Courier"
      ctx.fillText("(Sorry " + loser + ")", 200, 250);
      ctx.fillStyle = "#617282";
      ctx.font = "20px Courier"
      ctx.fillText("Click here to restart.", 270, 400);
    }
    return canvas;
  }

  player_win_restart() {
    if (this.state.player1score >= this.state.winScore || this.state.player2score >= this.state.winScore) {
      this.channel.push("play_next_game")
        .receive("ok", resp => {
          console.log("Game has started", resp.game)
          this.setState(resp.game);
        });
    }
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
        <div id={"lobbylist"} className="row">
          <div className="column">
            <p>Players:</p>
            <div id="playerList">
              <LobbyList lobbyList={this.state.lobbyList}/>
              <button id={"startButton"} onClick={this.startGame.bind(this)}>Start Game</button>
            </div>
          </div>
        </div>
      );
    } else {
      return (
        <div id={"gameboard"}>
          <h4>Click below to play!</h4>
          <div>
          <canvas id={"canvas"} ref="canvas" tabIndex={-1} width={800} height={600} onKeyDown={this.on_key.bind(this)} onClick={this.player_win_restart.bind(this)}/>
          </div>
          <div>
          <h4>Rules:</h4>
          <h5>Use the left and right (or up and down) arrow keys to move your paddle</h5>
          <h5>Points are awarded for breaking blocks (1 pt) and scoring on your opponent (10 pts)</h5>
          <h5>Your opponent will gain points (5 pts) for letting your own ball pass your own goal line</h5>
          <h5>The first player to score 50 points will win</h5>

          </div>

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
