module Whitehall::Authority::Rules
  OrganisationRules = Struct.new(:actor, :subject) do
    def can?(action)
      case action
      when :create
        actor.gds_admin?
      when :edit
        actor.gds_admin? || actor_is_from_organisation_or_parent?(actor, subject)
      when :manage_featured_links
        actor.gds_admin? || actor.gds_editor? || managing_editor_for_org?(actor, subject)
      when :manage_important_board_members
        actor.gds_admin? || actor.gds_editor? || managing_editor_for_org?(actor, subject) || departmental_editor_for_org?(actor, subject)
      else
        false
      end
    end

  private

    def managing_editor_for_org?(actor, subject)
      actor.managing_editor? && actor_is_from_organisation_or_parent?(actor, subject)
    end

    def departmental_editor_for_org?(actor, subject)
      actor.departmental_editor? && actor_is_from_organisation?(actor, subject)
    end

    def actor_is_from_organisation?(actor, organisation)
      actor.organisation == organisation
    end

    def actor_is_from_organisation_or_parent?(actor, organisation)
      actor.organisation == organisation || actor.organisation.try(:has_child_organisation?, organisation)
    end
  end
end
