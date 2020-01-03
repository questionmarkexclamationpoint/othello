module Othello
  module Util
    NormalDistributionGenerator = Distribution::Normal.rng
    WideNormalDistributionGenerator = Distribution::Normal.rng(0, 5)
    def self.sigmoid(x)
      1.0 / (1.0 + Math::E ** (-x.to_f))
    end
    def self.sigmoid_prime(x)
      (Math::E ** x.to_f) / ((Math::E ** x.to_f + 1) ** 2)
    end
    def self.random_normal
      NormalDistributionGenerator.call
    end
    def self.random_wide_normal
      WideNormalDistributionGenerator.call
    end
    def self.cost_derivative(x, y)
      x - y
    end
    def self.opposite_color(color)
      color == :white ? :black : :white
    end
  end
end

class Array
    def sample!
        delete_at(rand(length))
    end
end