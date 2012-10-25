module Edition::LimitedAccess
  extend ActiveSupport::Concern

  def can_limit_access?
    true
  end

  def access_limited?
    read_attribute(:access_limited)
  end

  def accessible_by?(user)
    if access_limited?
      organisations.include?(user.organisation)
    else
      true
    end
  end
end