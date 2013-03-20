module Whitehall::Authority::Rules
  class WorldEditionRules < Whitehall::Authority::Rules::EditionRules
    protected
    def actor_can_handle_world_editions?
      if actor.gds_editor?
        true
      elsif actor.world_editor? || actor.world_writer?
        true
      else
        false
      end
    end
    def can_with_a_class?(action)
      actor_can_handle_world_editions? && super
    end
    def can_see?
      actor_can_handle_world_editions? && super
    end
  end
end
