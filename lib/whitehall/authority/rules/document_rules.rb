module Whitehall::Authority::Rules
  class DocumentRules
    attr_reader :actor, :subject
    def initialize(actor, subject)
      @actor = actor
      @subject = subject
    end

    def can?(action)
      actor.gds_editor? || actor.departmental_editor? || action == :create
    end
  end
end
