class Group < ActiveRecord::Base
  belongs_to :organisation

  validates :name, :organisation, presence: true

  extend FriendlyId
  friendly_id

  def destroyable?
    true
  end
end
