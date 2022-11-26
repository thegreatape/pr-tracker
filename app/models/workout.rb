class Workout
  attr_accessor :exercises
  attr_reader :date

  def initialize(date)
    @date = date
    @exercises = []
  end

end
