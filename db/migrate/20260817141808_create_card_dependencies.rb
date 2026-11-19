class CreateCardDependencies < ActiveRecord::Migration[8.2]
  def change
    create_table :card_dependencies, id: :uuid do |t|
      t.uuid :account_id, null: false
      t.uuid :card_id, null: false
      t.uuid :blocker_id, null: false

      t.timestamps

      t.index [ :account_id ]
      t.index [ :card_id, :blocker_id ], unique: true
      t.index [ :blocker_id ]
    end
  end
end
