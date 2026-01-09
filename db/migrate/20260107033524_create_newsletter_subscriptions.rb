class CreateNewsletterSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :newsletter_subscriptions do |t|
      t.string :email
      t.datetime :confirmed_at
      t.string :token
      t.datetime :unsubscribed_at

      t.timestamps
    end
    add_index :newsletter_subscriptions, :email, unique: true
    add_index :newsletter_subscriptions, :token, unique: true
  end
end
