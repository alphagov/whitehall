module Whitehall::Authority::Rules
  class MinisterialRoleRules < Struct.new(:actor, :subject)
    def can?(action)
      actor.gds_editor? && action == :reorder_cabinet_ministers
    end
  end
end
