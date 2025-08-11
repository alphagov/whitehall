module Whitehall::Authority::Rules
  class FatalityNoticeRules < Whitehall::Authority::Rules::EditionRules
  protected

    def actor_can_handle_fatalities?
      actor.gds_editor? || actor.organisation&.handles_fatalities?
    end

    def can_with_a_class?(action)
      actor_can_handle_fatalities? && super
    end

    def can_with_an_instance?(action)
      actor_can_handle_fatalities? && super
    end
  end
end
