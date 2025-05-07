module Workflow
  class Step < Data.define(:name, :show_action, :update_action, :included_in_create_journey)
    SUBSCHEMA_PREFIX = "embedded_".freeze

    ALL = [
      Step.new(:edit_draft, :edit_draft, :update_draft, true),
      Step.new(:embedded_objects, :embedded_objects, :redirect_to_next_step, true),
      Step.new(:review_links, :review_links, :redirect_to_next_step, false),
      Step.new(:internal_note, :internal_note, :update_internal_note, false),
      Step.new(:change_note, :change_note, :update_change_note, false),
      Step.new(:schedule_publishing, :schedule_publishing, :validate_schedule, false),
      Step.new(:review, :review, :validate_review_page, true),
      Step.new(:confirmation, :confirmation, nil, true),
    ].freeze

    def is_subschema?
      name.to_s.start_with?(SUBSCHEMA_PREFIX)
    end
  end
end
