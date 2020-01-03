module Othello
  class Board < Array
    attr_reader :finished, :width, :height

    def initialize(w = 8, h = 8)
      @width = w
      @height = h
      @padding = [[@width / 10, @height / 10].max + 1, 2].max
      reset
    end

    def deep_dup
      d = dup
      each.with_index do |row, i|
        d[i] = row.dup
      end

      d
    end

    def reset
      clear
      @height.times { self << Array.new(@width, :empty) }
      self[@height / 2 - 1][@width / 2 - 1] = :white
      self[@height / 2 - 1][@width / 2] = :black
      self[@height / 2][@width / 2 - 1] = :black
      self[@height / 2][@width / 2] = :white
    end

    def display(valid_moves = [])
      print pad_char(' ') * 2
      @width.times { |i| print pad_char((i + 'A'.ord).chr) }
      puts
      print pad_char(' ')
      (@width + 2).times { print pad_piece(:edge) }
      puts
      @height.times do |i|
        print pad_char((i + 1).to_s) + pad_piece(:edge)
        @width.times do |j|
          print valid_moves.include?([i, j]) ? pad_piece(:open) : pad_piece(self[i][j])
        end
        puts pad_piece(:edge)
      end
      print pad_char(' ')
      (@width + 2).times { print pad_piece(:edge) }
      counts = piece_counts([:white, :black])
      puts
      puts "White: #{counts[:white]}"
      puts "Black: #{counts[:black]}"
      puts
    end

    def valid_moves(color)
      enemy = color == :white ? :black : :white
      moves = []
      each.with_index do |row, i|
        row.each.with_index do |piece, j|
          if piece == color
            Constants::Directions.constants.map{ |c| Constants::Directions.const_get(c) }.each do |dir|
              i_prime = i + dir[0]
              j_prime = j + dir[1]
              found_enemy = false
              while piece_is(i_prime, j_prime, enemy)
                found_enemy = true
                i_prime += dir[0]
                j_prime += dir[1]
              end
              moves << [i_prime, j_prime] if found_enemy && piece_is(i_prime, j_prime, :empty)
            end
          end
        end
      end
      moves
    end

    def valid_move?
      ! (valid_moves(:white).empty? && valid_moves(:black).empty?)
    end

    def piece_counts(pieces = Constants::PIECES.keys)
      hash = {}
      pieces.each do |piece|
        hash[piece] = 0
      end
      each do |row|
        row.each do |piece|
          hash[piece] += 1 if pieces.include?(piece)
        end
      end

      hash
    end

    def winner
      counts = piece_counts([:black, :white])
      return :tie if counts[:white] == counts[:black]

      counts[:white] > counts[:black] ? :white : :black
    end

    def piece_is(i, j, piece)
      !self[i].nil? && self[i][j] == piece
    end

    def place(move, color)
      self[move[0]][move[1]] = color
      flip(move, color) + 1
    end

    def flip(move, color)
      y, x = move
      enemy_color = Util.opposite_color(color)
      flipped = 0
      Constants::Directions.constants.map{ |c| Constants::Directions.const_get(c) }.each do |dir|
        y_prime = y + dir[0]
        x_prime = x + dir[1]
        while self[y_prime] && piece_is(y_prime, x_prime, enemy_color)
          y_prime += dir[0]
          x_prime += dir[1]
        end
        next unless piece_is(y_prime, x_prime, color)

        y_prime -= dir[0]
        x_prime -= dir[1]
        while piece_is(y_prime, x_prime, enemy_color)
          self[y_prime][x_prime] = color
          flipped += 1
          y_prime -= dir[0]
          x_prime -= dir[1]
        end
      end

      flipped
    end

    private

    def pad_piece(piece)
      pad_char(Constants::PIECES[piece])
    end

    def pad_char(char)
      "%-#{@padding}.3s" % char
    end
  end
end