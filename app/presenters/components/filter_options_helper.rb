class Components::FilterOptionsPresenter
  attr_reader :form_action, :reset_fields_link

  VALID_FILTER_OPTION_COMPONENTS = %w[input textarea select_with_search select date_input checkboxes radio].freeze

  def initialize(local_assigns)
    @action = local_assigns[:action]
    @anchor = local_assigns[:anchor] || ""
    @reset_link_query_string = local_assigns[:anchor] || ""

    @form_action = @action + @anchor
    @reset_fields_link = @action + @reset_link_query_string + @anchor
  end

  def valid_filter_type?(filter_type)
    VALID_FILTER_OPTION_COMPONENTS.include?(filter_type)
  end
end
