module Whitehall::Authority::Rules
  class StandardEditionRules < Whitehall::Authority::Rules::EditionRules
  protected

    def can_with_an_instance?(action)
      permitted_organisations = subject.class.config.authorised_organisations
      super && (permitted_organisations.nil? || permitted_organisations.include?(actor.organisation.content_id))
    end

    def can_with_a_class?(action)
      if subject.respond_to?(:config)
        permitted_organisations = subject.config.authorised_organisations
        return false unless (permitted_organisations.nil? || permitted_organisations.include?(actor.organisation.content_id))
      end
      actor.gds_admin? && super
    end
  end
end
