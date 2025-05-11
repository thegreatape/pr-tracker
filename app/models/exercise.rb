class Exercise < ApplicationRecord
    has_many :synonyms, class_name: "Exercise", foreign_key: "synonym_of_id"
    belongs_to :synonym_of, class_name: "Exercise", optional: true

end
