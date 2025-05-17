require 'workout'
require 'exercise_set'
require 'weightroom_dot_uk_parser'
require 'reddit_markdown_parser'

class Parser
  Exercise = Struct.new(:name, keyword_init: true)
  Workout = Struct.new(
    :exercise_sets,
    :raw_text,
    keyword_init: true
  )
  ExerciseSet = Struct.new(
    :bodyweight,
    :duration_seconds,
    :weight_lbs,
    :reps,
    :exercise,
    :line_number,
    keyword_init: true
  )

  def parse(contents)
    workout = if contents =~ /^\#/
      WeightroomDotUkParser.new.parse(contents)
    else
      RedditMarkdownParser.new.parse(contents)
    end
    workout.raw_text = contents
    workout
  end
end
