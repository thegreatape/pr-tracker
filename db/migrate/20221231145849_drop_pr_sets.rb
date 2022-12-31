class DropPrSets < ActiveRecord::Migration[7.0]
  def change
    drop_table :pr_sets
  end
end
