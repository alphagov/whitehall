module Whitehall::Authority::Rules
  class EditionRules
    attr_reader :actor, :subject
    def initialize(actor, subject)
      @actor = actor
      @subject = subject
    end

    def can?(action)
      if actor.gds_editor?
        gds_editor_can?(action)
      elsif actor.departmental_editor?
        departmental_editor_can?(action)
      else
        departmental_writer_can?(action)
      end
    end

    private
    def gds_editor_can?(action)
      case action.to_s.downcase
      when 'approve'
        can_approve?
      else
        can_see?
      end
    end

    def can_approve?
      if subject.force_published?
        subject.creator != actor
      else
        subject.state == 'submitted'
      end
    end

    def can_see?
      if subject.access_limited?
        (subject.organisations & actor.organisations).any?
      else
        true
      end
    end

    def departmental_editor_can?(action)
      case action.to_s.downcase
      when 'approve'
        can_approve?
      when 'unpublish'
        false
      else
        can_see?
      end
    end

    def departmental_writer_can?(action)
      case action.to_s.downcase
      when 'approve', 'unpublish', 'force_publish', 'publish', 'reject'
        false
      else
        can_see?
      end
    end

  end
end
