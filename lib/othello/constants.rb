module Othello
  module Constants
    module Directions
      UP = [-1, 0].freeze
      DOWN = [1, 0].freeze
      LEFT = [0, -1].freeze
      RIGHT = [0, 1].freeze
      UP_LEFT = [-1, -1].freeze
      UP_RIGHT = [-1, 1].freeze
      DOWN_LEFT = [1, -1].freeze
      DOWN_RIGHT = [1, 1].freeze
    end

    module Pieces
      WHITE = 'O'.freeze
      BLACK = 'X'.freeze
      EMPTY = '.'.freeze
      EDGE = '*'.freeze
    end

    PIECES = {
      white: '■'.freeze,
      black: '□'.freeze,
      empty: ' '.freeze,
      edge: '*'.freeze,
      open: '•'.freeze
    }.freeze
  end
end
