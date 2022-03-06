require 'workout'
require 'exercise_set'

class Parser
  # looks likes:
  # #Reverse ring fly
  EXERCISE_NAME_RE = /\s*#(.*)\s*/

  # TODO make these readable with extended re?
  SETS_RE = /(\d+)\s*x\s*(\d+)\s*x\s*(\d+)/

  def parse(contents)
    workout = Workout.new
    current_exercise = nil
    contents.split("\n").each do |line|
      if match = EXERCISE_NAME_RE.match(line)
        puts "exercise"
        current_exercise = Exercise.new(match[1])
        workout.exercises << current_exercise
      elsif match = SETS_RE.match(line)
        puts "sets"
        current_exercise.sets << ExerciseSet.new(reps: match[2].to_i, weight_lbs: match[1].to_i)
      end
    end
    workout
  end
end
