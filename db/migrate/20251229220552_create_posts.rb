class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.string :url
      t.text :body
      t.integer :post_type, null: false, default: 0
      t.integer :tag
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.integer :score, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.datetime :edited_at

      t.timestamps
    end
    add_index :posts, [ :status, :created_at ]
    add_index :posts, :url
  end
end
