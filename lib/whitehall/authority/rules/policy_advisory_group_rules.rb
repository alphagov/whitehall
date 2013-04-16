module Whitehall::Authority::Rules
  class PolicyAdvisoryGroupRules < Struct.new(:actor, :subject)
    def can?(action)
      actor.gds_editor? && action == :delete
    end
  end
end
