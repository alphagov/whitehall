module Workflow
  class Step < Data.define(:name, :show_action, :update_action)
    SUBSCHEMA_PREFIX = "embedded_".freeze

    ALL = [
      Step.new(:edit_draft, :edit_draft, :update_draft),
      Step.new(:review_links, :review_links, :redirect_to_next_step),
      Step.new(:internal_note, :internal_note, :update_internal_note),
      Step.new(:change_note, :change_note, :update_change_note),
      Step.new(:schedule_publishing, :schedule_publishing, :validate_schedule),
      Step.new(:review, :review, :validate_review_page),
      Step.new(:confirmation, :confirmation, nil),
    ].freeze

    def is_subschema?
      name.to_s.start_with?(SUBSCHEMA_PREFIX)
    end
  end
end
