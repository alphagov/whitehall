class StandardEditionMigrator::RecipeForLegacyEditionableDocument < StandardEditionMigrator::BaseRecipe
  def legacy_presenter
    StandardEditionMigrator::LegacyPresenter
  end

  def build_edition(legacy_record)
    edition_attrs = {
      configurable_document_type: "test_type",
      updated_at: legacy_record.updated_at.rfc3339,
      first_published_at: legacy_record.created_at.rfc3339,
      major_change_published_at: legacy_record.updated_at.rfc3339,
      creator: User.last,
      document: legacy_record.document,
    }
    edition = StandardEdition.new(edition_attrs)

    legacy_record.translations.each do |translation|
      # Still operating on the newly initialized Edition in memory - careful use of `find_or_initialize_by`
      edition.translations.find_or_initialize_by(locale: translation.locale).update(
        title: title(translation),
        summary: summary(translation),
        block_content: {
          "field_attribute" => translation.body.to_s,
        },
      )
    end

    @artefacts_to_save = edition.translations
    edition
  end

  def editorial_remark
    "Migrated legacy editionable document to StandardEdition"
  end

  def title(_legacy_record)
    "Title"
  end

  def summary(_legacy_record)
    "summary"
  end
end
