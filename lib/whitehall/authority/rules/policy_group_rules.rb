module Whitehall::Authority::Rules
  PolicyGroupRules = Struct.new(:actor, :subject) do
    def can?(action)
      actor.gds_editor? && action == :delete
    end
  end
end
