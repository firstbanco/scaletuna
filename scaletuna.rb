#!/usr/bin/env ruby

require "curses"
include Curses
require "aws-sdk"
C = Aws::AutoScaling::Client.new
Q = Queue.new
P = Thread.new do
  loop {
    Q << C
      .describe_auto_scaling_groups
      .auto_scaling_groups
      .select{|a| a.auto_scaling_group_name[/#{ARGV[0]||"."}/]}
    sleep 1
  }
end
init_screen
begin
  crmode
  selected = [0,0]
  stdscr.keypad = true
  stdscr.timeout = 100
  asc = Q.pop
  updated = Time.now
  loop {
    unless Q.empty?
      asc = Q.pop 
      updated = Time.now
    end
    selection = asc[selected[0]]
    setpos(0,0)
    addstr "min     max     desired name      updated:#{updated}"
    asc.each_with_index{|e,i|
      i==selected.first && attron(A_REVERSE) || attroff(A_REVERSE)
      [e.min_size,
       e.max_size,
       e.desired_capacity,
       e.auto_scaling_group_name].each_with_index{|v,j|
        j==selected.last && attron(A_BOLD) || attroff(A_BOLD)
        setpos(i+1,j*8)
        addstr v.to_s[0...cols-j*8]
      }
    }
    refresh
    begin
      case getch
      when KEY_UP
        selected[0]=[selected[0]-1,0].max
      when KEY_DOWN
        selected[0]=[selected[0]+1,asc.length].min
      when KEY_LEFT      
        C.set_desired_capacity(auto_scaling_group_name:selection.auto_scaling_group_name,
                               desired_capacity:selection.desired_capacity-1,
                               honor_cooldown:false)
        selection.desired_capacity-=1
      when KEY_RIGHT
        C.set_desired_capacity(auto_scaling_group_name:selection.auto_scaling_group_name,
                               desired_capacity:selection.desired_capacity+1,
                               honor_cooldown:false)
        selection.desired_capacity+=1
      end
    rescue Aws::AutoScaling::Errors::ValidationError => err
    end
  }
  refresh
ensure
  close_screen
end
