class Exercise < ApplicationRecord
    has_many :synonyms, class_name: "Exercise", foreign_key: "synonym_of_id"
    belongs_to :synonym_of, class_name: "Exercise", optional: true

    def unlink_synonym(synonym)
        return false unless synonyms.include?(synonym)
        synonym.update(synonym_of: nil)
    end
end
