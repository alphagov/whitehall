class UserNeed < ActiveRecord::Base
  belongs_to :organisation

  def to_s
    "As a #{user} I need to #{need} in order to #{goal}"
  end
end
