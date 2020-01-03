module Othello
  module Player
    class Base
      attr_accessor :color, :board
      def initialize(board, color = :white)
        @board = board
        @color = color
      end

      def make_move(legal_moves, print = true)
        raise NotImplementedError
      end

      def prompt_move(legal_moves, show_prompts = true)
        if legal_moves.empty?
          print 'You have no legal moves. Sorry!' if show_prompts
          return nil
        end
        print "#{@color.to_s.capitalize}, please make a move: " if show_prompts
        begin
          move = make_move(legal_moves, show_prompts)
        rescue MalformedMoveError
          print 'Invalid move. Try again: ' if show_prompts
          retry
        rescue NotFlankingError
          print 'That move is not flanking. Try again: ' if show_prompts
          retry
        rescue OutOfBoardError
          print 'That move is not within the board. Try again: ' if show_prompts
          retry
        end
        puts if show_prompts

        move
      end

      private

      def to_move_string(move)
        "#{('A'.ord + move[1]).chr}#{move[0] + 1}"
      end
    end
  end
end