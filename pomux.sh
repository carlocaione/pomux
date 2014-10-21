#!/bin/sh

time_session_min=1
time_short_break_min=1
time_long_break_min=1

color_session="#[fg=mycolor,bg=mycolor]#[fg=default]%s#[fg=mycolor,bg=mycolor]"
color_short_break="#[fg=mycolor,bg=mycolor]#[fg=red,bold]%s#[fg=mycolor,bg=mycolor]"
color_long_break="#[fg=mycolor,bg=mycolor]#[fg=red,bold]%s#[fg=mycolor,bg=mycolor]"

msg_start_session="Session started"
msg_start_short_break="Start short break"
msg_stop_short_break="Stop short break"
msg_start_long_break="Start long break"
msg_stop_long_break="Stop long break"

file_tmux_pipe=$HOME/.pomux-tmux
file_lock=$HOME/.pomux-lock

notify_exe="notify-send"

num_short_breaks=4

pb_length=20
pb_enable=1

[ -f $file_lock ] && exit 0
trap "{ rm -f $file_tmux_pipe $file_lock; exit 255; }" EXIT INT
echo $$ > $file_lock

wait_for_usr2()
{
	local catch=0
	trap "catch=1" USR2
	while [ "$catch" -eq 0 ]; do
		sleep 1
	done
	trap - USR2
}

s_to_m()
{
	printf "%02d:%02d" $(($1 / 60)) $(($1 % 60))
}

progress_bar()
{
	local time_left=$1
	local time_tot=$2
	local pb_len=$3
	local n_cur=$(($pb_len - ($time_left * $pb_len / $time_tot)))

	local cnt=1

	printf "%2d%% [" "$(($time_left * 100 / $time_tot))"
	while [ "$cnt" -le "$pb_len" ]; do
		if [ "$cnt" -le "$n_cur" ]; then
			printf "."
		else
			printf "="
		fi

		cnt=$((cnt + 1))
	done
	printf "]"
}

print_status()
{
	local step=$1
	local color=$2
	local time_left=$3
	local time_tot=$4
	local pb_len=$5
	local pb_enable=$6

	local str=""

	[ "$pb_enable" -ne 0 ] && str=$(progress_bar $time_left $time_tot $pb_len)
	str="$str $(s_to_m $time_left)"
	str="$str $step"

	printf $color "$str"
}

time_session_sec=$((time_session_min * 60))
time_short_break_sec=$((time_short_break_min * 60))
time_long_break_sec=$((time_long_break_min * 60))

step="P"
cur_step_sec=$time_session_sec
cur_step_sec_tot=$time_session_sec
cur_step_color=$color_session
n_short_breaks=0

while true
do
	cur_step_sec=$((cur_step_sec - 1))
	print_status $step $cur_step_color $cur_step_sec $cur_step_sec_tot $pb_length $pb_enable > $file_tmux_pipe

	sleep 1

	if [ "$cur_step_sec" -eq 0 ]; then

		case "$step" in
		P)
			if [ "$n_short_breaks" -eq "$num_short_breaks" ]; then
				[ ! -z "$notify_exe" -a ! -z "$msg_start_long_break" ] && $notify_exe "$msg_start_long_break"
				cur_step_sec_tot=$time_long_break_sec
				cur_step_color=$color_long_break
				step="LB"
				n_short_breaks=0
			else
				[ ! -z "$notify_exe" -a ! -z "$msg_start_short_break" ] && $notify_exe "$msg_start_short_break"
				cur_step_sec_tot=$time_short_break_sec
				cur_step_color=$color_short_break
				step="SB"
			fi
			;;

		SB | LB)
			if [ "$step" = "SB" ]; then
				n_short_breaks=$((n_short_breaks + 1))
				[ ! -z "$notify_exe" -a ! -z "$msg_stop_short_break" ] && $notify_exe "$msg_stop_short_break"
			else
				[ ! -z "$notify_exe" -a ! -z "$msg_stop_long_break" ] && $notify_exe "$msg_stop_long_break"
			fi

			cur_step_sec_tot=$time_session_sec
			cur_step_color=$color_session
			step="P"
			wait_for_usr2
			$notify_exe "$msg_start_session"
			;;
		esac

		cur_step_sec=$cur_step_sec_tot
	fi

done

exit 0
