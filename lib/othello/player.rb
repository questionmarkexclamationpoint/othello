module Othello
  module Player
    Dir["#{__dir__}/*"].each{|file| require file}
  end
end