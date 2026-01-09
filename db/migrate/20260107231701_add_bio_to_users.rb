class AddBioToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :bio, :text
    add_column :users, :website, :string
    add_column :users, :github_username, :string
    add_column :users, :twitter_username, :string
    add_column :users, :linkedin_url, :string
  end
end
