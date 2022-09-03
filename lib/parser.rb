require 'workout'
require 'exercise_set'
require 'weightroom_dot_uk_parser'
require 'reddit_markdown_parser'

class Parser
  SYNONYMS = {
    "Bench" => "Bench Press",
    "Bss" => "Bulgarian Split Squat",
    "Cable Upright Rows" => "Cable Upright Row",
    "Chin" => "Chin Up",
    "Dips" => "Dip",
    "Front Squats" => "Front Squat",
    "Hammer Curls" => "Hammer Curl",
    "Inc Bp" => "Incline Bench",
    "Incline Db Press" => "Incline Dumbbell Press",
    "Kb Press" => "Kettlebell Press",
    "Kb Row" => "Kettlebell Row",
    "Kb Snatch" => "Kettlebell Snatch",
    "Kb Swing" => "Kettlebell Swing",
    "Lat Pd" => "Lat Pulldown",
    "Oh Tri Ex" => "Oh Tri Ext",
    "Ohp" => "Overhead Press",
    "Pendlay Row" => "Barbell Row",
    "Rdl" => "Romanian Deadlift",
    "Rear Delt Flies 4x12x25," => "",
    "Rear Delt Flies" => "Rear Delt Fly",
    "Seal Rows" => "Seal Row",
    "Ssb" => "Safety Bar Squat",
    "Tbdl" => "Trap Bar Deadlift",
    "Trap Bar Deads" => "Trap Bar Deadlift",
    "Trap Bar Dl" => "Trap Bar Deadlift",
    "Tri Pushdowns" => "Tri Pushdown",
    "Yukon Bar Squat" => "Squat",
    "Yukon Squat" => "Squat"
  }

  def parse(contents, date)
    if contents =~ /^\#/
      WeightroomDotUkParser.new.parse(contents, date)
    else
      RedditMarkdownParser.new.parse(contents, date)
    end
  end
end
