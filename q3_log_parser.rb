require 'debug'
require './lib/q3_parser.rb'

parser = Q3_parser.new('./files/qgames.log')
parser.parse
debugger