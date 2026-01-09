class CreateFlags < ActiveRecord::Migration[8.1]
  def change
    create_table :flags do |t|
      t.references :user, null: false, foreign_key: true
      t.references :flaggable, polymorphic: true, null: false
      t.integer :reason, null: false
      t.text :description
      t.datetime :resolved_at
      t.references :resolved_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :flags, [ :user_id, :flaggable_type, :flaggable_id ], unique: true, name: "index_flags_on_user_and_flaggable"
  end
end
