require 'neural-network'
require_relative 'othello/constants'
require_relative 'othello/board'
require_relative 'othello/player'
require_relative 'othello/game'
require_relative 'othello/exceptions'
require_relative 'othello/util'

def main
  Othello::Game.new.play
end

main if __FILE__ == $0
