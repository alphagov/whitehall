module ConfigurableContentBlocks
  class NationApplicability < BaseBlock
    ALL_NATIONS = "all".freeze
    NATION_KEYS = %w[england scotland wales northern_ireland].freeze

    def options
      [
        { label: "Applies to all UK nations", value: ALL_NATIONS, checked: selected.include?(ALL_NATIONS) },
      ] + NATION_KEYS.map do |nation_key|
        {
          label: "Does not apply to #{nation_key.titleize}",
          value: nation_key,
          checked: selected.include?(nation_key),
        }
      end
    end

  private

    def selected
      Array(value)
    end

    def template_name
      "nation_applicability"
    end
  end
end
