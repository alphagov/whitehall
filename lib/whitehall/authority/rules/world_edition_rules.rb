module Whitehall::Authority::Rules
  class WorldEditionRules < Whitehall::Authority::Rules::EditionRules
    protected
    def actor_can_handle_world_editions?
      if actor.gds_editor?
        true
      elsif actor.world_editor? || actor.world_writer?
        true
      else
        # returning true here makes this whole ruleset redundant, but
        # it's not clear if this will always be the case once world is
        # live, so lets leave it for now
        true
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
