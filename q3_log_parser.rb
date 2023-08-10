require "awesome_print"
require 'debug'
require './lib/q3_parser.rb'
require './lib/q3_data_report.rb'

parser = Q3_parser.new('./files/qgames.log') #parse infos from log

game_report = Q3_data_report.new(parser.games) #using parsed infos, calculate report

ap(game_report.report, {indent: 2, index: false}) #print report with awesome print gem