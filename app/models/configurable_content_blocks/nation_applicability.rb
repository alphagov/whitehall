module ConfigurableContentBlocks
  class NationApplicability < BaseBlock
    ALL_NATIONS = "all".freeze
    NATION_KEYS = %w[england scotland wales northern_ireland].freeze
    def self.cast(value)
      return [] unless value.is_a?(Hash)

      selected = value["selected"] || []
      alternative_urls = value["alternative_urls"] || {}

      selected.map { |nation| { "nation" => nation, "alternative_url" => alternative_urls[nation] }.compact_blank }
    end

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
      entries.find { |entry| entry["nation"] == nation_key }&.dig("alternative_url")
    end

  private

    def entries
      self.class.cast(value)
    end

    def selected
      entries.map { |entry| entry["nation"] }
    end

    def template_name
      "nation_applicability"
    end
  end
end
