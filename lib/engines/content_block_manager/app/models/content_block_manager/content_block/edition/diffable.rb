module ContentBlockManager
  module ContentBlock::Edition::Diffable
    extend ActiveSupport::Concern

    def generate_diff
      diff = {}
      unless document.is_new_block?
        diff["title"] = [previous_edition.title, title] if previous_edition.title != title
        diff["details"] = details_diff if details_diff.any?
        diff["lead_organisation"] = [previous_org.name, lead_organisation.name] if lead_organisation != previous_org
        diff["instructions_to_publishers"] = [previous_edition.instructions_to_publishers, instructions_to_publishers] if previous_edition.instructions_to_publishers != instructions_to_publishers
      end
      diff
    end

    def previous_edition
      @previous_edition ||= document.editions.includes(:edition_organisation, :organisation)[-2]
    end

    def previous_org
      previous_edition.lead_organisation
    end

    def details_diff
      @details_diff ||= generate_details_diff
    end

    def generate_details_diff(previous_details = previous_edition.details, current_details = details)
      diff = {}
      keys = [*previous_details&.keys, *current_details&.keys].uniq
      keys.each do |key|
        previous_value = previous_details&.fetch(key, nil)
        new_value = current_details&.fetch(key, nil)
        if previous_value.is_a?(String) || new_value.is_a?(String)
          next unless previous_value != new_value

          diff[key] = [previous_value, new_value]
        elsif previous_value.is_a?(Hash) || new_value.is_a?(Hash)
          diff[key] = generate_details_diff(previous_value, new_value)
        end
      end
      diff
    end
  end
end
