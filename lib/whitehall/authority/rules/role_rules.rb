module Whitehall::Authority::Rules
  RoleRules = Struct.new(:actor, :subject) do
    def can?(action)
      if action == :reorder_cabinet_ministers
        return actor.gds_editor?
      end

      if subject.ministerial?
        return actor.gds_editor? || actor.managing_editor? || actor.departmental_editor?
      end

      true
    end
  end
end
