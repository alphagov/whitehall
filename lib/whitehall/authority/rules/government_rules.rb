module Whitehall::Authority::Rules
  class GovernmentRules < Struct.new(:actor, :subject)
    def can?(action)
      case action
      when :manage
        actor.gds_admin?
      else
        false
      end
    end
  end
end
