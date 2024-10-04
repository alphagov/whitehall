##
# Helper methods for use with the "select-with-search" component.
# This wraps and extends the Select component's helper methods to add support for option groups.
##
module GovukPublishingComponents
  module Presenters
    class SelectWithSearchHelper
#       include ActionView::Helpers::FormOptionsHelper

#       attr_reader :options, :selected_option

      delegate :describedby,
               :error_id,
               :error_message,
               :hint_id,
               :hint,
               :label_classes,
               :select_classes,
               to: :@select_helper

      def initialize(local_assigns)
        @select_helper = SelectHelper.new(local_assigns.except(:options, :grouped_options))
#         @options = local_assigns[:options]
#         @grouped_options = local_assigns[:grouped_options]
#         @include_blank = local_assigns[:include_blank]
        @local_assigns = local_assigns
      end

      def css_classes
        classes = %w[app-c-select-with-search govuk-form-group]
        classes << "govuk-form-group--error" if error_message
        classes
      end

      def options_html
        tmp = @local_assigns[:grouped_options]

        # # We need to turn the following structure...
        #
        # [
        #   [
        #     "",
        #     [
        #       {
        #         text: "All types",
        #         value: "",
        #         selected: selected.blank?,
        #       },
        #     ],
        #   ],
        #   [
        #     "Types",
        #     type_options_container(user).map do |text, value|
        #       {
        #         text:,
        #         value:,
        #         selected: selected == value,
        #       }
        #     end,
        #   ],
        # ]

        # # ...into the following:
        #
        # [
        #   {
        #     value: 'Option 1',
        #     text: 'Option 1',
        #   },
        #   {
        #     value: 'Option 2',
        #     text: 'Option 2',
        #   },
        #   {
        #     text: 'Group 1',
        #     choices: [
        #       {
        #         value: 'Option 3',
        #         text: 'Option 3',
        #         selected: true,
        #       },
        #       {
        #         value: 'Option 4',
        #         text: 'Option 4',
        #       }
        #     ]
        #   }
        # ]

        return unless tmp

        tmp = tmp.map do |nested_array|
          label = nested_array[0]
          values = nested_array[1]

          if label == "" && values.count == 1
            "<option value='#{values.first[:value]}' #{values.first[:selected] ? 'selected' : ''}>#{values.first[:text]}</option>"
          else
            options = values.map do |opt|
              "<option value='#{opt[:value]}' #{opt[:selected] ? 'selected' : ''}>#{opt[:text]}</option>"
            end
            "<optgroup label='#{label}'>#{options.join('')}</optgroup>"
          end
        end

        # tmp = tmp.map do |option_or_group|
        #   if option_or_group[:choices]
        #     options = option_or_group[:choices].map do |opt|
        #       "<option value='#{opt[:value]}' #{opt[:selected] ? 'selected' : ''}>#{opt[:text]}</option>"
        #     end
        #     "<optgroup label='#{option_or_group[:text]}'>#{options.join('')}</optgroup>"
        #   else
        #     "<option value='#{option_or_group[:value]}' #{option_or_group[:selected] ? 'selected' : ''}>#{option_or_group[:text]}</option>"
        #   end
        # end
        tmp.join("").html_safe

#         if @grouped_options.present?
#           # blank_option_if_include_blank +
#             grouped_options_for_select(
#               transform_grouped_options(@grouped_options),
#               selected_option,
#             )
#         elsif @options.present?
#           # blank_option_if_include_blank +
#             options_for_select(
#               transform_options(@options),
#               selected_option,
#             )
#         end
      end

      def data_attributes
        {
          "module": "select-with-search",
        }.compact
      end

#     private

#       def transform_options(options)
#         options.map do |option|
#           @selected_option = option[:value] if option[:selected]
#           [
#             option[:text],
#             option[:value],
#           ]
#         end
#       end

#       def transform_grouped_options(grouped_options)
#         grouped_options.map do |(group, options)|
#           [group, transform_options(options)]
#         end
#       end

#       # def blank_option_if_include_blank
#       #   return "".html_safe if @include_blank.blank?

#       #   options_for_select([["", ""]])
#       # end
    end
  end
end
 