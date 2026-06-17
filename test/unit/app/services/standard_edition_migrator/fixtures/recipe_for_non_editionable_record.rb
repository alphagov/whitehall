class StandardEditionMigrator::RecipeForNonEditionableRecord < StandardEditionMigrator::BaseRecipe
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
    queue_for_saving(SitewideSetting.new(key: "foo")) # Proof of concept
    edition.translations.each do |translation|
      # More realistic proof of concept - and we can test that edition_id is set properly
      queue_for_saving(translation)
    end
    edition
  end
end
