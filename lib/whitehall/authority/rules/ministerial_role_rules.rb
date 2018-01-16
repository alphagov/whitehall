module Whitehall::Authority::Rules
  MinisterialRoleRules = Struct.new(:actor, :subject) do
    def can?(action)
      actor.gds_editor? && action == :reorder_cabinet_ministers
    end
  end
end
