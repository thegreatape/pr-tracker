class AddLatestToPrSets < ActiveRecord::Migration[7.0]
  def change
    add_column :pr_sets, :latest, :boolean, default: false
  end
end
