class CreateModerationItems < ActiveRecord::Migration[8.1]
  def change
    create_table :moderation_items do |t|
      t.references :moderatable, polymorphic: true, null: false
      t.integer :reason, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.references :moderator, null: true, foreign_key: { to_table: :users }
      t.datetime :resolved_at

      t.timestamps
    end
    add_index :moderation_items, :status
  end
end
