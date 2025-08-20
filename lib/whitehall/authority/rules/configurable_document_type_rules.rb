module Whitehall::Authority::Rules
  class ConfigurableDocumentTypeRules
    def initialize(actor, subject)
      @actor = actor
      @subject = subject
    end

    def can?(_action)
      permitted_organisations = subject.settings["organisations"]
      permitted_organisations.nil? || permitted_organisations.include?(actor.organisation.content_id)
    end

  private

    attr_reader :actor, :subject
  end
end
