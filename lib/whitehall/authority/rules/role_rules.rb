module Whitehall::Authority::Rules
  RoleRules = Struct.new(:actor, :subject) do
    def can?(action)
      actor.gds_editor? && action == :reorder_cabinet_ministers
    end
  end
end
