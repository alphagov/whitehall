module Whitehall::Authority::Rules
  class FatalityNoticeRules < Whitehall::Authority::Rules::EditionRules
    protected
    def actor_can_handle_fatalities?
      actor.gds_editor? || (actor.organisation && actor.organisation.handles_fatalities?)
    end
    def can_create_class?
      actor_can_handle_fatalities? && super
    end
    def can_see?
      actor_can_handle_fatalities? && super
    end
  end
end
