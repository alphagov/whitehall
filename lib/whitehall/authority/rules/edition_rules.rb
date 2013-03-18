module Whitehall::Authority::Rules
  class EditionRules
    def self.actions
      [
        'see', 'update', 'create', 'delete',
        'approve', 'publish', 'force_publish',
        'reject', 'make_fact_check', 'review_fact_check',
        'make_editorial_remark', 'review_editorial_remark',
        'limit_access', 'unpublish'
      ]
    end

    attr_reader :actor, :subject
    def initialize(actor, subject)
      @actor = actor
      @subject = subject
    end

    def can?(action)
      action = sanitized_action(action)
      return false unless valid_action?(action)
      if subject.is_a?(Class)
        can_with_a_class?(action)
      else
        can_with_an_instance?(action)
      end
    end

    def valid_action?(action)
      EditionRules.actions.include?(sanitized_action(action))
    end

    private
    def sanitized_action(action)
      action.to_s.downcase
    end

    def can_with_an_instance?(action)
      if !can_see?
        return false
      else
        if actor.gds_editor?
          gds_editor_can?(action)
        elsif actor.departmental_editor?
          departmental_editor_can?(action)
        else
          departmental_writer_can?(action)
        end
      end
    end

    def gds_editor_can?(action)
      case action
      when 'approve'
        can_approve?
      when 'publish'
        can_publish?
      else
        true
      end
    end

    def can_approve?
      subject.published_by != actor
    end

    def can_publish?
      subject.creator != actor
    end

    def can_with_a_class?(action)
      ['create', 'see'].include? action
    end

    def can_see?
      if subject.access_limited?
        (subject.organisations & [actor.organisation].compact).any?
      else
        true
      end
    end

    def departmental_editor_can?(action)
      case action
      when 'approve'
        can_approve?
      when 'publish'
        can_publish?
      when 'unpublish'
        false
      else
        true
      end
    end

    def departmental_writer_can?(action)
      case action
      when 'approve', 'publish', 'unpublish', 'force_publish', 'reject'
        false
      else
        true
      end
    end

  end
end
