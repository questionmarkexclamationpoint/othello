module Othello
  class Game
    attr_accessor :white, :black
    attr_reader :board, :player, :finished, :enemy, :turn

    def initialize(w = 8, h = 8)
      @board = Board.new(w, h)
    end

    def play(white, black, show_prompts = true)
      @white = white
      @white.color = :white
      @black = black
      @black.color = :black
      @turn = 1
      @player = black
      @enemy = white
      @board.reset
      @finished = false
      take_turn(show_prompts) until @finished
      result = @board.winner
      puts result == :tie ? "It's a tie!" : "#{result.to_s.capitalize} wins!" if show_prompts

      result
    end

    private

    def turn_finish
      @player, @enemy = @enemy, @player
      @turn += 1

      @turn
    end

    def take_turn(show_prompts = true)
      puts if show_prompts
      puts "Turn #{@turn}" if show_prompts
      black_moves = @board.valid_moves(:black)
      white_moves = @board.valid_moves(:white)
      moves = @player == @white ? white_moves : black_moves
      @board.display(moves) if show_prompts
      @finished = black_moves.empty? && white_moves.empty?
      return turn_finish if @finished

      move = @player.prompt_move(moves, show_prompts)
      return turn_finish if move.nil?

      @board.place(move, @player.color)
      turn_finish
    end
  end
end