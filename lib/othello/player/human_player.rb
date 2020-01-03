module Othello
  module Player
    class HumanPlayer < Base
      def make_move(legal_moves, print = true)
        y, x = to_move(gets)
        raise OutOfBoardError unless (0..@board.height - 1).include?(y) && (0..@board.width - 1).include?(x)

        raise NotFlankingError unless legal_moves.include?([y, x])

        [y, x]
      end

      private

      def to_move(move_string)
        move_string = move_string.downcase.chomp
        raise MalformedMoveError if move_string.length != 2

        x = (move_string[0].ord - 'a'.ord)
        y = move_string[1].to_i - 1

        [y, x]
      end
    end
  end
end