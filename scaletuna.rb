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
def message(msg)
  setpos(lines-1,0)
  clrtoeol
  addstr msg
  refresh
end
def quit(message = nil,code = 0)
  close_screen
  $stderr.puts message if message
  exit code
end
begin
  crmode
  selected = [0,2]
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
    addstr "min     max     desired current name      updated:#{updated}"
    asc.each_with_index{|e,i|
      [e.min_size,
       e.max_size,
       e.desired_capacity,
       e.instances.length,
       e.auto_scaling_group_name].each_with_index{|v,j|
        (i==selected.first && j==selected.last) && attron(A_BOLD) || attroff(A_BOLD)
        (i==selected.first || j==selected.last) && attron(A_REVERSE) || attroff(A_REVERSE)
        setpos(i+1,j*8)
        addstr v.to_s[0...cols-j*8]
      }
    }
    setpos(selected.first+1,selected.last*8)
    refresh
    change = 0
    begin
      case (ch = getch)
      when KEY_UP
        selected[0]=[selected[0]-1,0].max
      when KEY_DOWN
        selected[0]=[selected[0]+1,asc.length-1].min
      when KEY_LEFT      
        selected[1]=[selected[1]-1,0].max
      when KEY_RIGHT
        selected[1]=[selected[1]+1,2].min
      when KEY_ENTER,"\n".ord,"\r".ord,"+"
        change = +1
      when KEY_BACKSPACE,"-"
        change = -1
      when "q"
        quit "Exiting normally (q)"
      else
        message "#{ch} not mapped" if ch
      end
      if change!=0
        case selected[1]
        when 2 # desired_capacity
          new = selection.desired_capacity+change
          message "setting desired capacity to #{new}"
          C.set_desired_capacity(auto_scaling_group_name:
                                 selection.auto_scaling_group_name,
                                 desired_capacity:new,
                                 honor_cooldown:false)
          selection.desired_capacity = new
        when 0 # min_size
          new = selection.min_size+change
          message "setting min size to #{new}"
          C.update_auto_scaling_group(auto_scaling_group_name:
                                      selection.auto_scaling_group_name,
                                      min_size:new
                                      )
          selection.min_size = new
        when 1 # max_size
          new = selection.max_size+change
          message "setting max size to #{new}"
          C.update_auto_scaling_group(auto_scaling_group_name:
                                      selection.auto_scaling_group_name,
                                      max_size:new
                                      )
          selection.max_size = new
        end
      end
    rescue Aws::AutoScaling::Errors::ValidationError => err
      message err.to_s
    end
  }
  refresh
rescue Interrupt
  quit("Ctrl-c",130)
ensure
  close_screen
end
