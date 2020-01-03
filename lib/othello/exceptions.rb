module Othello
  class Error < Exception
  end

  class MalformedMoveError < Error
  end

  class OutOfBoardError < Error
  end

  class NotFlankingError < Error
  end
end