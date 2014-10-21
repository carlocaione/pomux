Description
===========

Pomux is an highly configurable script to have a pomodoro timer integrated in tmux.

Installation
============

Download the script or clone the repository in a local directory.

To have Pomux integrated in tmux you need to add a couple of lines in your tmux configuration file `.tmux.conf`.

	set-option -g status-right '#(cat ~/.pomux-tmux)'
	bind h run-shell "$TERMINAL setsid <install_dir>/pomux.sh -r >/dev/null 2>&1 < /dev/null &"

where `<install_dir>` is the directory containing the Pomux script.

The first line creates a new tmux status line containing the timer and the progress bar whereas the second line is used to bind Pomux to the `h` command key in tmux (change it at your convenience).

Configuration
=============

The script is shipped with reasonable default values for the configuration parameters but you can change them simply by editing the script.

* `time_pomodoro_min` minutes for one pomodoro
* `time_short_break` minutes for a short break
* `time_long_break` minutes for a long break
* `color_pomodoro` tmux status bar timer color for the pomodoro session
* `color_short_break` tmux status bar timer color for the short break
* `color_long_break` tmux status bar timer color for the long break
* `msg_start_pomodoro` message to notify at pomodoro start
* `msg_restart_pomodoro` message to notify at pomodoro restart
* `msg_start_short_break` message to notify at short break start
* `msg_stop_short_break` message to notify at short break stop
* `msg_start_long_break` message to notify at long break start
* `msg_stop_long_break` message to notify at long break stop
* `notify_exe` program used for notifying
* `num_short_breaks` number of short breaks before a long break
* `pb_lenght` progress bar length
* `pb_enable` progress bar enabled
* `file_tmux_pipe` file location for the file to be read by tmux (if you change the default location you must modify also the tmux configuration file)
* `file_lock` lock/pid file

Command line
============

Pomux can be started also by command line and it accepts three arguments:

* `-k` kill Pomux if it is running
* `-r` start a new pomodoro after a short/long break or restart the timer with a new pomodoro
* `-h` help

`Ctrl+C` to interrupt and cleanup. 

Usage with tmux keybinding
==========================

The default key binding in tmux for Pomux is `C+X, h` (where `C+X` is the prefix key for your tmux configuration). It is used for:

* Start the timer the first time with a new pomodoro
* Start a new pomodoro at the end of a short/long break
* Restart the timer from beginning

When `C+X, h` is pressed for the first time, the first pomodoro is started. During a pomodoro session the timer looks like:

`97% [.===================] 24:19 (P)`

If `C+X, h` is pressed again the pomodoro is restarted.

At the end of the pomodoro session the short break starts and the status bar in tmux looks like:

`93% [..==================] 04:39 (SB)`

When the short break is over Pomux waits for the user input before starting a new pomodoro. The user can start a new pomodoro using the usual `C+X, h` command.

After `num_short_breaks` (4 by default) short breaks the following break is longer and the timer during the long break looks like:

`89% [...=================] 13:27 (LB)`

At the end of the long break the cycle starts from the beginning.
