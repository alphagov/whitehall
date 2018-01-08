module Whitehall::Authority::Rules
  class OrganisationRules < Struct.new(:actor, :subject)
    def can?(action)
      case action
      when :create
        actor.gds_admin?
      when :edit
        actor.gds_admin? || actor_is_from_organisation_or_parent?(actor, subject)
      when :manage_featured_links
        actor.gds_admin? || actor.gds_editor? || (actor.managing_editor? && actor_is_from_organisation_or_parent?(actor, subject))
      else
        false
      end
    end

  private

    def actor_is_from_organisation_or_parent?(actor, organisation)
      actor.organisation == organisation || actor.organisation.try(:has_child_organisation?, organisation)
    end
  end
end
