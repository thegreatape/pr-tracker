class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :exercise_sets
  has_many :workouts
  has_many :exercises, through: :exercise_sets

  def search_exercises(query, exclude_exercise: nil)
    query = exercises
      .where("name ILIKE ?", "%#{query}%")
      .where(synonym_of_id: nil)
      .distinct
      .limit(5)

    if exclude_exercise
      query
        .where.not(id: exclude_exercise&.id)
        .where.not(id: exclude_exercise&.synonyms&.pluck(:id))
    else
      query
    end
  end
end
