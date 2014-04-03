module Whitehall::Authority::Rules
  class PolicyGroupRules < Struct.new(:actor, :subject)
    def can?(action)
      actor.gds_editor? && action == :delete
    end
  end
end
