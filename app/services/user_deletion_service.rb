class UserDeletionService
  DELETED_USER_USERNAME = "usuniety".freeze

  def self.deleted_user_email
    "deleted@#{ENV.fetch('APP_HOST', 'tabdevs.pl')}"
  end

  def initialize(user)
    @user = user
  end

  def delete!
    ActiveRecord::Base.transaction do
      anonymize_content
      cleanup_associations
      @user.destroy!
    end
  end

  private

  def anonymize_content
    deleted_user = find_or_create_deleted_user
    @user.posts.update_all(author_id: deleted_user.id)
    @user.comments.update_all(author_id: deleted_user.id)
    Notification.where(actor_id: @user.id).update_all(actor_id: nil)
  end

  def cleanup_associations
    @user.notifications.delete_all
    @user.votes.delete_all
    @user.magic_links.delete_all
    @user.bans.delete_all
    @user.bookmarks.delete_all
    @user.flags.delete_all
  end

  def find_or_create_deleted_user
    User.find_or_create_by!(email: self.class.deleted_user_email) do |u|
      u.username = DELETED_USER_USERNAME
      u.role = :user
      u.status = :active
    end
  end
end
