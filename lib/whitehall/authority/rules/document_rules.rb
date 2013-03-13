module Whitehall::Authority::Rules
  class DocumentRules
    attr_reader :actor, :subject
    def initialize(actor, subject)
      @actor = actor
      @subject = subject
    end
    def can?(action)
      if actor.gds_editor? || actor.departmental_editor?
        true
      elsif action.to_s.downcase == 'create'
        true
      else
        false
      end
    end
  end
end
