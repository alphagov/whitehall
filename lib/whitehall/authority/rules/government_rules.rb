module Whitehall::Authority::Rules
  class GovernmentRules < Struct.new(:actor, :subject)
    def can?(action)
      case action
      when :create, :edit
        actor.gds_admin?
      else
        false
      end
    end
  end
end
