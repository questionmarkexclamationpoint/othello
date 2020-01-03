module Othello
  module Player
    class BreadthFirstAiPlayer < Base

      def initialize(board)
        super
        @losing = false
      end

      private

      def best_move(valid_moves)
        valid_moves.map{ |m| [m, moves_to_win(m)] }.max{ |a, b| a.last <=> b.last }[0]
      end

      def moves_to_win(move)
        boards = [@board.deep_dup]
        boards.first.place(move, @color)
        to_place = Util.opposite_color(@color)
        moves_made = 1
        until boards.any?{ |b| !b.valid_move? && b.winner == @color}
          moves_made += 1
          boards.each do |b|
            b.valid_moves(to_place).each do |m|
              boards << b.deep_dup
              boards.last.place(m, to_place)
            end
            boards.delete(b)
          end
          to_place = Util.opposite_color(to_place)
        end

        moves_made
      end
    end
  end
end