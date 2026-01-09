class CreateBans < ActiveRecord::Migration[8.1]
  def change
    create_table :bans do |t|
      t.references :user, null: false, foreign_key: true
      t.references :moderator, null: false, foreign_key: { to_table: :users }
      t.text :reason, null: false
      t.integer :ban_type, null: false, default: 0
      t.datetime :expires_at

      t.timestamps
    end
    add_index :bans, [ :user_id, :expires_at ]
  end
end
