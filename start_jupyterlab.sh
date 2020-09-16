#!/bin/sh
tmux new -d -s jlab
tmux send-keys -t jlab "firefox & jupyter-lab &" ENTER
