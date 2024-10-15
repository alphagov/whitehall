module Whitehall::Authority::Rules
  class LandingPageRules < Whitehall::Authority::Rules::EditionRules
  protected

    def actor_can_handle_landing_pages?
      actor.gds_admin?
    end

    def can_with_a_class?(action)
      actor_can_handle_landing_pages? && super
    end

    def can_see?
      actor_can_handle_landing_pages? && super
    end
  end
end
