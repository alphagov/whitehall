module Whitehall::Authority::Rules
  class StandardEditionRules < Whitehall::Authority::Rules::EditionRules
  protected

    def can_with_an_instance?(action)
      permitted_organisations = subject.type_instance.settings["organisations"]
      super && (permitted_organisations.nil? || permitted_organisations.include?(actor.organisation.content_id))
    end

    def can_with_a_class?(action)
      actor.gds_admin? && super
    end
  end
end
