#!/bin/bash

export MIX_ENV=prod
export PORT=5791

echo "Stopping old copy of app, if any..."

_build/prod/rel/breakout-pong/bin/memory stop || true

echo "Starting app..."

# Foreground for testing and for systemd
_build/prod/rel/breakout_pong/bin/breakout_pong foreground
