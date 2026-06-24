class StandardEditionMigrator::RecipeForNonEditionableRecord < StandardEditionMigrator::BaseRecipe
  def initialize
    @artefacts_to_save = []
    super
  end

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
    @artefacts_to_save << SitewideSetting.new(key: "foo") # Proof of concept
    edition.translations.each do |translation|
      # More realistic proof of concept - and we can test that edition_id is set properly
      @artefacts_to_save << translation
    end
    edition
  end

  def after_save_edition(edition, _legacy_record)
    @artefacts_to_save.each do |artefact|
      # Set the edition_id on any artefacts that need it, and save them
      artefact.edition_id = edition.id if artefact.respond_to?(:edition_id=)
      artefact.save!
    end
  end
end
