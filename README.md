# cloudwalk-qe-test
This is a Quake 3 log parser, as part of Cloudwalk test for Quality Engineering position.

![quake 3](https://media.tenor.com/o0EZph8ggmMAAAAC/carnmode-carnagejohnson.gif)
# Requirements
Ruby <= 3

# Instalation
I strongly recommend RVM: https://rvm.io/

Just follow the instructions on their site!

### Then

`$ bundle install`

# Running

`$ ruby q3_log_parser.rb`

# Tests
`$ bundle exec rspec`

# Changes
To read another log file, change path [here](https://github.com/puloms/cloudwalk-qe-test/blob/42d5fa9ab4ebc851d9f397b7774bd93cc4f107ea/q3_log_parser.rb#L6), considering `.` as root directory of the project.
