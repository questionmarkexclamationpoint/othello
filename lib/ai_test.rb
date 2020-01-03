require_relative 'othello'
require 'neural-network'
require 'thread'
require 'descriptive-statistics'
require 'yaml'

def neural_test
  srand(42069)
  game = Othello::Game.new
  computers = Othello::Population.new(size: 25, member_class: Othello::NeuralAiPlayer, args: game.board)
  if File.exists?("best_1.yml")
    genes = YAML.load(File.read("best_1.yml"))
    computers.current_members.each do |member|
      member.genes = genes
      member.rebuild_brain
    end
  end
  #other = Othello::HumanPlayer.new(game.board)
  other = Othello::RandomPlayer.new(game.board)
  #other = Othello::HeuristicAiPlayer.new(game.board)
  games_to_play = 20
  num_games = computers.size * games_to_play
  loop do
    index = 0
    games_won = 0
    games_to_play.times do
      computers.size.times do |i|
        players = [computers[i], other]
        white = players.sample!
        black = players.sample!
        game.play(white, black, false)
        games_won += game.board.winner == computers[i].color ? 1 : 0
        computers[i].calc_fitness
        index += 1
        puts "#{index} / #{num_games}"
      end
    end
    clone = computers.best.replicate
    game.play(computers.best, clone, true)
    stats = DescriptiveStatistics::Stats.new(computers.current_members.map{|m| m.fitness})
    puts
    puts "Generation: #{computers.generation}"
    puts "Won: #{games_won}"
    puts "Average: #{stats.mean}"
    puts "Median: #{stats.median}"
    puts "Min: #{stats.min}"
    puts "Max: #{stats.max}"
    puts "Relative deviation: #{stats.relative_standard_deviation}"
    puts
    10.downto(1) do |i|
      next unless File.exists?("best_#{i}.yml")
      File.rename("best_#{i}.yml", "best_#{i + 1}.yml")
    end
    File.delete("best_11.yml") if File.exists?("best_10.yml")
    File.write("best_1.yml", computers.best.to_yaml)
    computers.current_members.each(&:kill_brain)
    computers.evolve!
  end
end

def heuristic_test
  game = Othello::Game.new
  ai = Othello::NeuralAiPlayer.new(game.board)
  if File.exists?("best_1.yml")
    genes = YAML.load(File.read("best_1.yml"))
    ai.genes = genes
    ai.rebuild_brain
  end
  other = Othello::HumanPlayer.new(game.board)
  wins = 0
  to_play = 1000
  to_play.times do |i|
    game.play(ai, other, true)
    wins += 1 if game.board.winner == ai.color
    puts "#{i} / #{to_play}"
  end
  puts "#{wins} / #{to_play}"
  game.play(ai, other)
end

def breadth_first_test
  game = Othello::Game.new
  ai = Othello::BreadthFirstAiPlayer.new(game.board)
  other = Othello::HumanPlayer.new(game.board)
  wins = 0
  to_play = 100
  to_play.times do |i|
    game.play(ai, other, true)
    wins += 1 if game.board.winner == ai.color
    puts "#{i} / #{to_play}"
  end
  puts "#{wins} / #{to_play}"
  game.play(ai, other)
end

neural_test if __FILE__ == $0
#heuristic_test
