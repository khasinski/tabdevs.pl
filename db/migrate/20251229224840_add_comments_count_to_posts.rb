class AddCommentsCountToPosts < ActiveRecord::Migration[8.1]
  def up
    # Add comments counter cache
    add_column :posts, :comments_count, :integer, default: 0, null: false

    # Populate existing counts (only visible comments)
    execute <<-SQL
      UPDATE posts SET comments_count = (
        SELECT COUNT(*) FROM comments
        WHERE comments.post_id = posts.id AND comments.status = 0
      )
    SQL

    # Add normalized_url for faster duplicate detection
    add_column :posts, :normalized_url, :string
    add_index :posts, :normalized_url

    # Populate normalized URLs
    Post.where.not(url: nil).find_each do |post|
      normalized = post.url.to_s.downcase
                       .sub(%r{^https?://(www\.)?}, "")
                       .sub(%r{/$}, "")
      post.update_column(:normalized_url, normalized)
    end

    # Add missing performance indexes (only those that don't exist)
    add_index :posts, [ :author_id, :created_at ], if_not_exists: true
    add_index :comments, [ :post_id, :status, :parent_id ], if_not_exists: true
    add_index :comments, [ :author_id, :created_at ], if_not_exists: true
  end

  def down
    remove_column :posts, :comments_count
    remove_column :posts, :normalized_url
    remove_index :posts, [ :author_id, :created_at ], if_exists: true
    remove_index :comments, [ :post_id, :status, :parent_id ], if_exists: true
    remove_index :comments, [ :author_id, :created_at ], if_exists: true
  end
end
