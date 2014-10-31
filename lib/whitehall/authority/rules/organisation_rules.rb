module Whitehall::Authority::Rules
  class OrganisationRules < Struct.new(:actor, :subject)
    def can?(action)
      case action
      when :manage_featured_links
        actor.gds_admin? || actor.gds_editor? || (actor.managing_editor? && actor.organisation == subject)
      when :create
        actor.gds_admin?
      when :edit
        actor.gds_admin? || actor.organisation == subject || actor.organisation.try(:has_child_organisation?, subject)
      else
        false
      end
    end
  end
end
