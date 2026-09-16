module ConfigurableContentBlocks
  class NationApplicability < BaseBlock
    ALL_NATIONS = "all".freeze
    NATION_KEYS = %w[england scotland wales northern_ireland].freeze

    def options
      [ALL_NATIONS, *NATION_KEYS].map do |key|
        {
          label: key == ALL_NATIONS ? "Applies to all UK nations" : "Does not apply to #{key.titleize}",
          value: key,
          checked: selected.include?(key),
        }
      end
    end

    def nation_url_field_keys
      NATION_KEYS
    end

    def selected_path
      @path.push("selected")
    end

    def alternative_url_path(nation_key)
      @path.push(["alternative_urls", nation_key])
    end

    def alternative_url_for(nation_key)
      value&.dig("alternative_urls", nation_key)
    end

  private

    def selected
      Array(value&.dig("selected"))
    end

    def template_name
      "nation_applicability"
    end
  end
end
