class AddSynonymOfToExercises < ActiveRecord::Migration[7.0]
  def change
    add_reference :exercises, :synonym_of, foreign_key: { to_table: :exercises }
  end
end
