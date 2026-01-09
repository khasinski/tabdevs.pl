class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :comments }
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.text :body, null: false
      t.integer :score, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.datetime :edited_at

      t.timestamps
    end
    add_index :comments, [ :post_id, :parent_id ]
    add_index :comments, :status
  end
end
