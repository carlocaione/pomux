#!/bin/sh

t_m_session=1
t_m_short_break=1
t_m_long_break=1

c_session="#[fg=mycolor,bg=mycolor]#[fg=default]%02d:%02d#[fg=mycolor,bg=mycolor]"
c_short_break="#[fg=mycolor,bg=mycolor]#[fg=red,bold]%02d:%02d#[fg=mycolor,bg=mycolor]"
c_long_break="#[fg=mycolor,bg=mycolor]#[fg=red,bold]%02d:%02d#[fg=mycolor,bg=mycolor]"

f_tmux_pipe=$HOME/.pomux-tmux

s_to_m()
{
	printf $1 $(($2 / 60)) $(($2 % 60))
}

t_s_session=$((t_m_session * 60))
t_s_short_break=$((t_m_short_break * 60))
t_s_long_break=$((t_m_long_break * 60))

step="session"
t_s=$t_s_session
c_s=$c_session

while true
do
	t_s=$((t_s - 1))
	s_to_m $c_s $t_s > $f_tmux_pipe

	if [ $t_s -eq 0 ]; then

		case $step in
		session)
			echo "Session is over"
			t_s=$t_s_short_break
			c_s=$c_short_break
			step="short_break"
			;;
		short_break)
			echo "Short break is over"
			t_s=$t_s_long_break
			c_s=$c_long_break
			step="long_break"
			;;
		long_break)
			echo "Long break is over"
			t_s=$t_s_session
			c_s=$c_session
			step="session"
			;;
		esac
	fi

	sleep 1
done
