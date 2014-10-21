#!/bin/sh

t_m_session=1
t_m_short_break=1
t_m_long_break=1

c_session="#[fg=mycolor,bg=mycolor]#[fg=default]%s#[fg=mycolor,bg=mycolor]"
c_short_break="#[fg=mycolor,bg=mycolor]#[fg=red,bold]%s#[fg=mycolor,bg=mycolor]"
c_long_break="#[fg=mycolor,bg=mycolor]#[fg=red,bold]%s#[fg=mycolor,bg=mycolor]"

s_start_session="Session started"
s_start_short_break="Start short break"
s_stop_short_break="Stop short break"
s_start_long_break="Start long break"
s_stop_long_break="Stop long break"

f_tmux_pipe=$HOME/.pomux-tmux
f_lock_file=$HOME/.pomux-lock
n_exe="notify-send"
n_short_breaks_tot=4
n_length_pb=20
b_enable_pb=1

t_s_session=$((t_m_session * 60))
t_s_short_break=$((t_m_short_break * 60))
t_s_long_break=$((t_m_long_break * 60))

[ -f $f_lock_file ] && exit 0
trap "{ rm -f $f_tmux_pipe $f_lock_file; exit 255; }" EXIT INT
echo $$ > $f_lock_file

wait_for_usr2()
{
	local catch=0
	trap "catch=1" USR2
	while [ $catch -eq 0 ]; do
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
	local n_cur
	n_cur=$(($1 * $3 / $2))
	n_cur=$(($3 - $n_cur))

	local x=1

	printf "%2d%% [" "$(($1 * 100 / $2))"
	while [ $x -le $3 ]; do
		if [ $x -le $n_cur ]; then
			printf "."
		else
			printf "="
		fi

		x=$((x + 1))
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

	if [ $pb_enable	-ne 0 ]; then
		str=$(progress_bar $time_left $time_tot $pb_len)
	fi
	str="$str $(s_to_m $time_left)"
	str="$str $step"

	printf $color "$str"
}

step="P"
t_s=$t_s_session
t_s_tot=$t_s_session
c_s=$c_session
n_short_breaks=0

while true
do
	t_s=$((t_s - 1))
	print_status $step $c_s $t_s $t_s_tot $n_length_pb $b_enable_pb > $f_tmux_pipe

	sleep 1

	if [ $t_s -eq 0 ]; then

		case "$step" in
		P)
			if [ $n_short_breaks -eq $n_short_breaks_tot ]; then
				$n_exe "$s_start_long_break"
				t_s=$t_s_long_break
				t_s_tot=$t_s_long_break
				c_s=$c_long_break
				step="LB"
				n_short_breaks=0
			else
				$n_exe "$s_start_short_break"
				t_s=$t_s_short_break
				t_s_tot=$t_s_short_break
				c_s=$c_short_break
				step="SB"
			fi
			;;

		SB | LB)
			if [ "$step" = "SB" ]; then
				n_short_breaks=$((n_short_breaks + 1))
				$n_exe "$s_stop_short_break"
			else
				$n_exe "$s_stop_long_break"
			fi

			t_s=$t_s_session
			t_s_tot=$t_s_session
			c_s=$c_session
			step="P"
			wait_for_usr2
			$n_exe "$s_start_session"
			;;
		esac
	fi

done

exit 0
