class Version < ActiveRecord::Base
  attr_accessible :state

  def user
    User.find(whodunnit)
  end
end