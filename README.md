# Scaletuna

    scaletuna [autoscaling group name regex]

Curses utility gem that shows your AWS EC2 Autoscaling groups in a table (including current size). You can then tune the desired_capacity, min, and max with your keyboard.

The only argument is a regular expression that is matched against your autoscaling groups, and only shows those that match it.

Keys: 
- (`up`,`down`,`left`,`right`): Select parameter to modify
- (`+`,`return`): Increase by one
- (`-`,`backspace`): Decrease by one
- (`q`): Quit and print all operations performed


## Installation

    gem install scaletuna
