class UserNeed < ActiveRecord::Base
  belongs_to :organisation

  def self.existing_content(field_type)
    UserNeed.order(field_type).pluck(field_type).uniq
  end

  def to_s
    "As a(n) #{user} I need to #{need} in order to #{goal}"
  end
end
