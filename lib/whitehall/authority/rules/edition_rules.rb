module Whitehall::Authority::Rules
  class EditionRules
    def self.actions
      %i[
        approve
        create
        delete
        export
        force_publish
        limit_access
        make_editorial_remark
        make_fact_check
        mark_political
        perform_administrative_tasks
        publish
        reject
        see
        select_government_for_history_mode
        unpublish
        unwithdraw
        update
      ]
    end

    attr_reader :actor, :subject

    def initialize(actor, subject)
      @actor = actor
      @subject = subject
    end

    def can?(action)
      raise "Invalid authorisation action for an edition" unless EditionRules.actions.include?(action)

      if subject.is_a?(Class)
        can_with_a_class?(action)
      elsif subject.historic?
        can_with_a_historic_instance?(action)
      else
        can_with_an_instance?(action)
      end
    end

  private

    def can_with_a_class?(action)
      case action
      when :perform_administrative_tasks
        actor.gds_admin?
      when :export
        actor.gds_admin? || actor.gds_editor? || actor.managing_editor? || actor.departmental_editor?
      when :create, :see
        true
      else
        false
      end
    end

    def can_with_an_instance?(action)
      return false if access_limit_enforced?

      case action
      when :approve
        (actor.gds_admin? || actor.gds_editor? || actor.managing_editor? || actor.departmental_editor?) &&
          subject.published_by != actor && (!subject.scheduled? || subject.scheduled_by != actor)
      when :force_publish
        (actor.gds_admin? || actor.gds_editor? || actor.managing_editor? || actor.departmental_editor?) &&
          !subject.scheduled?
      when :mark_political
        actor.gds_admin? || actor.gds_editor? || actor.managing_editor?
      when :perform_administrative_tasks
        actor.gds_admin?
      when :publish
        (actor.gds_admin? || actor.gds_editor? || actor.managing_editor? || actor.departmental_editor?) &&
          subject.submitted_by != actor && !subject.scheduled?
      when :reject
        actor.gds_admin? || actor.gds_editor? || actor.managing_editor? || actor.departmental_editor?
      when :select_government_for_history_mode
        actor.gds_admin? || actor.gds_editor?
      when :unpublish
        actor.gds_admin? || actor.managing_editor?
      when :unwithdraw
        actor.gds_admin? || actor.gds_editor? || actor.managing_editor?
      else
        true
      end
    end

    def can_with_a_historic_instance?(action)
      action == :see || actor.gds_editor? || actor.gds_admin?
    end

    def access_limit_enforced?
      if subject.access_limited?
        organisations = subject.organisations
        organisations += subject.edition_organisations.map(&:organisation) if subject.respond_to?(:edition_organisations)
        organisations.exclude?(actor.organisation)
      else
        false
      end
    end
  end
end
