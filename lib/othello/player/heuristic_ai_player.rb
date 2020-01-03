module Othello
  module Player
    class HeuristicAiPlayer < Base
      def make_move(valid_moves, show_prompts = true)
        move = best_move(valid_moves)
        print to_move_string(move) if show_prompts

        move
      end

      private

      def best_move(valid_moves)
        piece_counts = {}
        other = Util.opposite_color(@color)
        valid_moves.each do |move|
          temp_board = @board.deep_dup
          flipped = temp_board.place(move, @color)
          max_other_flipped = 0
          temp_board.valid_moves(other).each do |other_move|
            other_flipped = temp_board.deep_dup.place(other_move, other)
            max_other_flipped = other_flipped if other_flipped > max_other_flipped
          end
          piece_counts[move] = flipped - max_other_flipped
        end

        piece_counts.max_by{ |k, v| v }[0]
      end
    end
  end
end