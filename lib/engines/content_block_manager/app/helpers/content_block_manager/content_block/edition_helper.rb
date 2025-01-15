module ContentBlockManager
  module ContentBlock
    module EditionHelper
      def summary_list_entries_for_details(details, title_style: :standard)
        details.map { |key, value|
          if value.is_a?(Array)
            value.each.with_index(1).map do |items, i|
              {
                field: title_style == :confirm ? "New #{key.humanize.downcase.singularize} #{i}" : "#{key.humanize.singularize} #{i}",
                value: list_entry_for_items(items),
              }
            end
          else
            {
              field: title_style == :confirm ? "New #{key.humanize.downcase}" : key.humanize,
              value:,
            }
          end
        }.flatten
      end

      def list_entry_for_items(items)
        tag.ul(class: "govuk-list") do
          items.map do |embedded_key, embedded_value|
            concat(tag.li("#{embedded_key.humanize}: #{embedded_value}"))
          end
        end
      end
    end
  end
end
