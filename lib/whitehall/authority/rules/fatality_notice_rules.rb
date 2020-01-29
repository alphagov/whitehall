module Whitehall::Authority::Rules
  class FatalityNoticeRules < Whitehall::Authority::Rules::EditionRules
  protected

    def actor_can_handle_fatalities?
      if actor.gds_editor?
        true
      elsif actor.world_editor? || actor.world_writer?
        false
      else
        (actor.organisation && actor.organisation.handles_fatalities?)
      end
    end

    def can_with_a_class?(action)
      actor_can_handle_fatalities? && super
    end

    def can_see?
      actor_can_handle_fatalities? && super
    end
  end
end
