Description
===========

Pomux is an highly configurable script to have a pomodoro timer integrated in tmux.

Installation
============

To have Pomux integrated in tmux you need to add a couple of lines in your tmux configuration file.

	set-option -g status-right '#(cat ~/.pomux-tmux)'
	bind h run-shell "$TERMINAL setsid <install_dir>/pomux.sh -r >/dev/null 2>&1 < /dev/null &"

where `<install_dir>` is the directory containing the pomux script.
