class Version < ActiveRecord::Base
  attr_accessible :state

  def user
    if whodunnit
      User.find(whodunnit)
    else
      nil
    end
  end
end
