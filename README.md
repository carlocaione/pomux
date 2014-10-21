Description
===========

Pomux is an highly configurable script to have a pomodoro timer integrated in tmux.

Installation
============

To have Pomux integrated in tmux you need to add a couple of lines in your tmux configuration file `.tmux.conf`.

	set-option -g status-right '#(cat ~/.pomux-tmux)'
	bind h run-shell "$TERMINAL setsid <install_dir>/pomux.sh -r >/dev/null 2>&1 < /dev/null &"

where `<install_dir>` is the directory containing the pomux script.
The first line create a new status-right containing the timer and the progress bar. The second line is used to bind Pomux to the `h` command key in tmux, change it at your convenience.

Usage
=====

The key binding in tmux `C+X, h` (where `C+X` is the prefix key for your tmux configuration) is used for:

* Start the timer
* Restart the timer from beginning
* Start a new pomodoro at the end of a short/long break

Pressing the `C+X, h` for the first time, the first pomodoro is started. During a pomodoro session the timer looks like:

`97% [.===================] 24:19 (P)`

Pressing again `C+X,h` the pomodoro session is restarted.
At the end of the pomodoro session the short break starts.
