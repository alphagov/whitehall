class Group < ActiveRecord::Base
  belongs_to :organisation

  validates :name, :organisation, presence: true

  extend FriendlyId
  friendly_id

  default_scope order(:name)

  def destroyable?
    true
  end
end
