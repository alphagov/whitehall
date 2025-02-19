module ContentBlockManager
  module ContentBlock::Edition::Diffable
    extend ActiveSupport::Concern

    def generate_diff
      diff = {}
      unless document.is_new_block?
        diff["title"] = ContentBlock::DiffItem.new(previous_value: previous_edition.title, new_value: title) if previous_edition.title != title
        diff["details"] = details_diff if details_diff.any?
        diff["lead_organisation"] = ContentBlock::DiffItem.new(previous_value: previous_org.name, new_value: lead_organisation.name) if lead_organisation != previous_org
        diff["instructions_to_publishers"] = ContentBlock::DiffItem.new(previous_value: previous_edition.instructions_to_publishers, new_value: instructions_to_publishers) if previous_edition.instructions_to_publishers != instructions_to_publishers
      end
      diff
    end

    # This is a temporary solution to allow us to specifically set the previous edition when backfilling
    # the diffs. This can be deleted once the rake task has been run
    def previous_edition=(edition)
      @previous_edition = edition
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

          diff[key] = ContentBlock::DiffItem.new(previous_value:, new_value:)
        elsif previous_value.is_a?(Hash) || new_value.is_a?(Hash)
          diff[key] = generate_details_diff(previous_value, new_value)
        end
      end
      diff
    end
  end
end
