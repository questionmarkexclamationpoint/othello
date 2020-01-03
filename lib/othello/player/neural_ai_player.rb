module Othello
  module Player
    class NeuralAiPlayer < Base
      #include Othello::Organism TODO

      attr_reader :brain, :fitness
      attr_accessor :name, :genes

      def initialize(board)
        super
        @fitness = 0
        @num_opponents = 0
        size = @board.width * @board.height
        @brain = NeuralNetwork.new([size * 2, size, size / 2, size])
        index = 0
        [:white, :black].each do |color|
          @board.each.with_index do |row, i|
            row.length.times do |j|
              @brain.name_neuron(0, index, [color, i, j])
              index += 1
            end
          end
        end
        index = 0
        @board.each.with_index do |row, i|
          row.length.times do |j|
            @brain.name_neuron(@brain.neurons.length - 1, index, [i, j])
            index += 1
          end
        end
        @name = random_name
        @genes = {
          brain: {
            weights: [],
            biases: []
          },
          mutation_rate: rand * 0.1,
          mutation_chance: rand * 0.1
        }
        @brain.biases.each do |layer|
          @genes[:brain][:biases] << []
          layer.each do |bias|
            @genes[:brain][:biases][-1] << bias
          end
        end
        @brain.weights.each do |layer|
          @genes[:brain][:weights] << []
          layer.each do |pre_layer|
            @genes[:brain][:weights][-1] << []
            pre_layer.each do |weight|
              @genes[:brain][:weights][-1][-1] << weight
            end
          end
        end
      end

      def make_move(legal_moves, show_prompts = true)
        other = @color == :white ? :black : :white
        [@color, other].each do |color|
          @board.each.with_index do |row, i|
            row.each.with_index do |piece, j|
              @brain[[color, i, j]] = piece == color ? 1.0 : 0.0
            end
          end
        end
        @brain.think
        move = @brain.names.select{ |k| legal_moves.include?(k) }.max_by{ |k, _| @brain[k] }[0]
        print to_move_string(move) if show_prompts

        move
      end

      def mutate!
        @fitness = 0
        @genes[:brain][:weights].each.with_index do |layer, i|
          layer.each.with_index do |pre_layer, j|
            pre_layer.each.with_index do |weight, k|
              new_val = mutated_normal_value(weight, @genes[:mutation_rate], @genes[:mutation_chance])
              #new_val = mutated_value(weight, -1, 1, @genes[:mutation_rate], @genes[:mutation_chance])
              @genes[:brain][:weights][i][j][k] = new_val
              @brain.weights[i][j][k] = new_val
            end
          end
        end
        @genes[:brain][:biases].each.with_index do |layer, i|
          layer.each.with_index do |bias, j|
            new_val = mutated_normal_value(bias, @genes[:mutation_rate], @genes[:mutation_chance])
            #new_val = mutated_value(bias, -1, 1, @genes[:mutation_rate], @genes[:mutation_chance])
            @genes[:brain][:biases][i][j] = new_val
            @brain.biases[i][j] = new_val
          end
        end
        @genes[:mutation_rate] = mutated_value(@genes[:mutation_rate], 0, 0.1, @genes[:mutation_rate], @genes[:mutation_chance])
        @genes[:mutation_chance] = mutated_value(@genes[:mutation_rate], 0, 0.1, @genes[:mutation_rate], 0.1)
        rebuild_brain

        self
      end

      def recombine(other)
        new_genes = {
          brain: {
            weights: [],
            biases: []
          },
          mutation_rate: 0,
          mutation_chance: 0
        }
        @genes[:brain][:weights].each.with_index do |layer, i|
          new_genes[:brain][:weights] << []
          layer.each.with_index do |pre_layer, j|
            new_genes[:brain][:weights][-1] << []
            pre_layer.each.with_index do |weight, k|
              new_genes[:brain][:weights][-1][-1] << [weight, other.genes[:brain][:weights][i][j][k]].sample
            end
          end
        end
        @genes[:brain][:biases].each.with_index do |layer, i|
          new_genes[:brain][:biases] << []
          layer.each.with_index do |bias, j|
            new_genes[:brain][:biases][-1] << [bias, other.genes[:brain][:biases][i][j]].sample
          end
        end
        new_genes[:mutation_rate] = [@genes[:mutation_rate], other.genes[:mutation_rate]].sample
        new_genes[:mutation_chance] = [@genes[:mutation_chance], other.genes[:mutation_chance]].sample

        new_organism = NeuralAiPlayer.new(@board)
        new_organism.genes = new_genes
        new_organism.rebuild_brain

        new_organism
      end

      def calc_fitness(increment_opponents = true)
        size = @board.height * @board.width
        empty = @board.piece_counts([:empty])[:empty].to_f
        count = @board.piece_counts([@color])[@color].to_f / (size - empty)
        f = 0.0
        if @board.winner == @color
          f = 1.0
          # f *= empty + 1
        elsif @board.winner == :tie
          f = 0.5
          # f *= empty + 1
        end
        f += count / size

        @fitness *= @num_opponents
        @fitness += f
        @num_opponents += 1 if increment_opponents
        @fitness /= @num_opponents

        @fitness
      end

      def replicate
        new_genes = {
          brain: {
            weights: [],
            biases: []
          },
          mutation_rate: 0,
          mutation_chance: 0
        }
        @genes[:brain][:weights].each do |layer|
          new_genes[:brain][:weights] << []
          layer.each do |pre_layer|
            new_genes[:brain][:weights][-1] << []
            pre_layer.each do |weight|
              new_genes[:brain][:weights][-1][-1] << weight
            end
          end
        end
        @genes[:brain][:biases].each do |layer|
          new_genes[:brain][:biases] << []
          layer.each do |bias|
            new_genes[:brain][:biases][-1] << bias
          end
        end
        new_genes[:mutation_rate] = @genes[:mutation_rate]
        new_genes[:mutation_chance] = @genes[:mutation_chance]

        new_organism = NeuralAiPlayer.new(board)
        new_organism.genes = new_genes
        new_organism.rebuild_brain

        new_organism
      end

      def kill_brain
        @brain = nil
      end

      def rebuild_brain
        size = @board.width * @board.height
        @brain = NeuralNetwork.new([size * 2, size, size / 2, size])
        index = 0
        [:white, :black].each do |color|
          @board.each.with_index do |row, i|
            row.length.times do |j|
              @brain.name_neuron(0, index, [color, i, j])
              index += 1
            end
          end
        end
        index = 0
        @board.each.with_index do |row, i|
          row.length.times do |j|
            @brain.name_neuron(@brain.neurons.length - 1, index, [i, j])
            index += 1
          end
        end
        @brain.weights = @genes[:brain][:weights]
        @brain.biases = @genes[:brain][:biases]

        @brain
      end

      def to_yaml
        @genes.to_yaml
      end
    end
  end
end
