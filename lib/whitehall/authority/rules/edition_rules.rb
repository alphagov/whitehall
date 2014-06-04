module Whitehall::Authority::Rules
  class EditionRules
    def self.actions
      [
        :see, :update, :create, :delete,
        :approve, :publish, :force_publish,
        :reject, :make_fact_check, :review_fact_check,
        :make_editorial_remark, :review_editorial_remark,
        :limit_access, :unpublish
      ]
    end

    attr_reader :actor, :subject
    def initialize(actor, subject)
      @actor = actor
      @subject = subject
    end

    def can?(action)
      return false unless valid_action?(action)
      if subject.is_a?(Class)
        can_with_a_class?(action)
      else
        can_with_an_instance?(action)
      end
    end

    def valid_action?(action)
      EditionRules.actions.include?(action)
    end

  private

    def can_with_an_instance?(action)
      if actor.can_force_publish_anything? && action == :force_publish
        return true
      elsif !can_see?
        return false
      elsif action == :unpublish && actor.managing_editor?
        return true
      else
        if actor.gds_editor?
          gds_editor_can?(action)
        elsif actor.departmental_editor?
          departmental_editor_can?(action)
        elsif actor.managing_editor?
          managing_editor_can?(action)
        elsif actor.world_editor?
          world_editor_can?(action)
        elsif actor.world_writer?
          world_writer_can?(action)
        elsif actor.scheduled_publishing_robot?
          scheduled_publishing_robot_can?(action)
        else
          departmental_writer_can?(action)
        end
      end
    end

    def gds_editor_can?(action)
      case action
      when :approve
        can_approve?
      when :publish
        can_publish?
      when :force_publish
        can_force_publish?
      when :unpublish
        false
      else
        true
      end
    end

    def can_approve?
      actor_is_not_publisher? && actor_is_not_scheduler?
    end

    def can_publish?
      actor_is_not_creator? && not_publishing_scheduled_edition_without_authority?
    end

    def can_force_publish?
      not_publishing_scheduled_edition_without_authority?
    end

    def actor_is_not_creator?
      subject.creator != actor
    end

    def actor_is_not_publisher?
      subject.published_by != actor
    end

    def actor_is_not_scheduler?
      !subject.scheduled? || subject.scheduled_by != actor
    end

    def not_publishing_scheduled_edition_without_authority?
      !subject.scheduled? || actor.can_publish_scheduled_editions?
    end

    def can_with_a_class?(action)
      [:create, :see].include? action
    end

    def world_actor?
      actor.world_editor? || actor.world_writer?
    end

    def can_see?
      if world_actor? && (subject.world_locations & actor.world_locations).empty?
        false
      elsif subject.access_limited?
        organisations = subject.organisations
        organisations += subject.edition_organisations.map(&:organisation) if subject.respond_to?(:edition_organisations)
        organisations.include?(actor.organisation)
      else
        true
      end
    end

    def departmental_editor_can?(action)
      case action
      when :approve
        can_approve?
      when :publish
        can_publish?
      when :force_publish
        can_force_publish?
      when :unpublish
        false
      else
        true
      end
    end

    def managing_editor_can?(action)
      departmental_editor_can?(action)
    end

    def world_editor_can?(action)
      departmental_editor_can?(action)
    end

    def departmental_writer_can?(action)
      case action
      when :approve, :publish, :unpublish, :force_publish, :reject
        false
      else
        true
      end
    end

    def world_writer_can?(action)
      departmental_writer_can?(action)
    end

    def scheduled_publishing_robot_can?(action)
      case action
      when :publish
        can_publish?
      else
        false
      end
    end
  end
end
