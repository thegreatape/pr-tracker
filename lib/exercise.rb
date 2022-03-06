class Exercise
  attr_reader :name
  attr_accessor :sets

  def initialize(name)
    @name = name
    @sets = []
  end
end
