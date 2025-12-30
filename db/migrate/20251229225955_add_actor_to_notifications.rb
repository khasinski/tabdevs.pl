class AddActorToNotifications < ActiveRecord::Migration[8.1]
  def change
    add_reference :notifications, :actor, null: true, foreign_key: { to_table: :users }
  end
end
