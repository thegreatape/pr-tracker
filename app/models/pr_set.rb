class PrSet < ApplicationRecord
  belongs_to :exercise

  def e1rm
    return weight_lbs.to_i if reps == 1

    if reps <= 10
      ((weight_lbs * 0.033 * reps) + weight_lbs).to_i
    end
  end
end
