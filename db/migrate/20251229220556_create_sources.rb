class CreateSources < ActiveRecord::Migration[8.1]
  def change
    create_table :sources do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.integer :source_type, null: false, default: 0
      t.boolean :enabled, null: false, default: true
      t.datetime :last_fetched_at

      t.timestamps
    end
  end
end
