module PermissionsChecker
  extend ActiveSupport::Concern

  def can?(action, subject)
    enforcer_for(subject).can?(action)
  end

  included do
    helper_method :can?
  end

private
  def enforcer_for(subject)
    actor = current_user || User.new
    Whitehall::Authority::Enforcer.new(actor, subject)
  end
end
