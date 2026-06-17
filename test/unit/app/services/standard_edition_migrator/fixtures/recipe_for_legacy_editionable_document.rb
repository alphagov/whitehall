class StandardEditionMigrator::RecipeForLegacyEditionableDocument < StandardEditionMigrator::BaseRecipe
  def legacy_presenter
    StandardEditionMigrator::HardcodedPresenter
  end

  def build_edition(legacy_record)
    edition_attrs = {
      configurable_document_type: "test_type",
      updated_at: legacy_record.updated_at.rfc3339,
      creator: User.last,
      document: legacy_record.document,
    }
    edition = StandardEdition.new(edition_attrs)

    legacy_record.translations.each do |translation|
      # Still operating on the newly initialized Edition in memory - careful use of `find_or_initialize_by`
      edition.translations.find_or_initialize_by(locale: translation.locale).update(
        title: "Title",
        summary: "Summary",
        block_content: {
          "field_attribute" => translation.body.to_s,
        },
      )
    end
    edition.translations.each do |translation|
      queue_for_saving(translation)
    end
    edition
  end
end
