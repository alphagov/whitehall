module Whitehall::Authority::Rules
  class OrganisationRules < Struct.new(:actor, :subject)
    def can?(action)
      case action
      when :manage_services_and_guidance
        actor.gds_editor? || (actor.managing_editor? && actor.organisation == subject)
      when :create
        actor.gds_admin?
      else
        false
      end
    end
  end
end
