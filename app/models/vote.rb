class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :votable, polymorphic: true

  validates :value, presence: true, inclusion: { in: [ -1, 1 ] }
  validates :user_id, uniqueness: { scope: [ :votable_type, :votable_id ] }

  scope :upvotes, -> { where(value: 1) }
  scope :downvotes, -> { where(value: -1) }
end
