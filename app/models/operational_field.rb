class OperationalField < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :fatality_notices

  extend FriendlyId
  friendly_id

  def published_fatality_notices
    fatality_notices.published
  end
end
