class StandardEditionMigrator::RecipeForNonEditionableRecord
  def legacy_presenter
    StandardEditionMigrator::HardcodedPresenter
  end

  def build_edition(legacy_record)
    edition_attrs = {
      configurable_document_type: "test_type",
      updated_at: legacy_record.updated_at.rfc3339,
      creator: User.last,
    }
    edition = StandardEdition.new(edition_attrs)

    # NOTE: implementation will vary depending on non-editionable model.
    # E.g. Organisation has `translations` we can iterate over, but TopicalEvent does not.
    legacy_record.translations.each do |translation|
      edition.translations.find_or_initialize_by(locale: translation.locale).update(
        title: translation.name,
        summary: "Summary",
        block_content: {
          # Hardcoded for simplicity, so we can check the payload comes out the same
          # for both the editionable and non-editionable test cases.
          "field_attribute" => "Old body",
        },
      )
    end
    edition
  end
end
