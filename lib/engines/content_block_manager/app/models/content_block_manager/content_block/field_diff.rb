module ContentBlockManager
  module ContentBlock
    class FieldDiff < Data.define(:field_name, :new_value, :previous_value)
      def self.all_for_edition(edition:)
        if edition.document.is_new_block?
          nil
        else
          field_diffs = []
          previous_edition = edition.document.editions.includes(:edition_organisation, :organisation)[-2]
          if previous_edition.title != edition.title
            field_diffs.append(new(field_name: "title", previous_value: previous_edition.title, new_value: edition.title))
          end
          if previous_edition.details != edition.details
            previous_edition.details.each do |key, value|
              next unless value != edition.details[key]

              field_diffs.append(new(field_name: key, previous_value: value, new_value: edition.details[key]))
            end
          end
          previous_org = previous_edition.lead_organisation
          new_org = edition.lead_organisation
          if new_org != previous_org
            field_diffs.append(new(
                                 field_name: "lead_organisation",
                                 previous_value: previous_org.name,
                                 new_value: edition.lead_organisation.name,
                               ))
          end
          if previous_edition.instructions_to_publishers != edition.instructions_to_publishers
            field_diffs.append(new(
                                 field_name: "instructions_to_publishers",
                                 previous_value: previous_edition.instructions_to_publishers,
                                 new_value: edition.instructions_to_publishers,
                               ))
          end
          field_diffs unless field_diffs.empty?
        end
      end
    end
  end
end
