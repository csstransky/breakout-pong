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
            player1x: 670,
            player1y: 100,
            player2x: 10,
            player2y: 10,
            player1score: 0,
            player2score: 0,
            height: 600,
            width: 700,
            upArrow: 38,
            downArrow: 40,
            loop: false,
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
    }

    got_view(view) {
        console.log("new view");
        this.setState(view.game);
    }

    initialize_game() {
        console.log("game restarted from browser side");
        this.channel.push("restart")
            .receive("ok", this.got_view.bind(this))
    }

    draw_canvas() {
        let canvas = this.refs.canvas;

        let ctx = canvas.getContext("2d");
        ctx.clearRect(0, 0, 800, 600);
        ctx.fillStyle = "#FF0000";
        ctx.fillRect(this.state.player2x, this.state.player2y, 30, 110);
        ctx.fillRect(this.state.player1x, this.state.player1y, 30, 110);
        ctx.fillRect(this.state.ballx, this.state.bally, 15,15);
        ctx.font = "40px Courier"
        ctx.fillText(this.state.player1score, 200, 40);
        ctx.fillText(this.state.player2score, 600, 40);

        return canvas;
    }

    on_key(ev) {
        console.log(ev.which);
        if (ev.which == 38 || ev.which == 37) { //this is the up arrow
            this.channel.push("onkey", {keypressed: "up"})
                .receive("ok", this.got_view.bind(this));
            this.draw_canvas();
        }
        if (ev.which == 40 || ev.which == 39) { //this is the down arrow
            this.channel.push("onkey", {keypressed: "down"})
                .receive("ok", this.got_view.bind(this));
            this.draw_canvas();
        }
        else {
            console.log("Key Pressed: Not an up or down key.")
        }
    }

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
