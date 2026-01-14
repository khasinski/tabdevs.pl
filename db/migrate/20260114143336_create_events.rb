class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.string :url
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :location
      t.string :address
      t.string :organizer
      t.string :source
      t.string :external_id
      t.string :event_type
      t.boolean :free

      t.timestamps
    end

    add_index :events, :external_id, unique: true
    add_index :events, :starts_at
    add_index :events, :source
    add_index :events, :event_type
  end
end
