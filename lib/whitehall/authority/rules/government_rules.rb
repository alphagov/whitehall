module Whitehall::Authority::Rules
  GovernmentRules = Struct.new(:actor, :subject) do
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
