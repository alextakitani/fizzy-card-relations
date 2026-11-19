class AddParentToCards < ActiveRecord::Migration[8.2]
  def change
    add_column :cards, :parent_id, :uuid
    add_index :cards, :parent_id
  end
end
