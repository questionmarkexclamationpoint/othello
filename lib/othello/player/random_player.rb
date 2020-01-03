module Othello
  module Player
    class RandomPlayer < Player
      def make_move(legal_moves, show_prompts = true)
        move = legal_moves.sample
        print to_move_string(move) if show_prompts

        move
      end
    end
  end
end