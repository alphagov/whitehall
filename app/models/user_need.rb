class UserNeed < ActiveRecord::Base
  belongs_to :organisation

  validates :user, :need, :goal, presence: true

  def self.existing_content(field_type)
    UserNeed.order(field_type).pluck(field_type).uniq
  end

  def to_s
    "As a(n) #{user} I need to #{need} so that #{goal}"
  end
end
