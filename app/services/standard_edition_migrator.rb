class StandardEditionMigrator
  def self.preview_migration(...)
    new.preview_migration(...)
  end

  def preview_migration(legacy_record, recipe)
    if legacy_record.is_a?(Edition)
      raise "An Edition was passed. You must pass the Document instead (so that we can migrate all of its Editions)"
    end

    # If passed an Editionable legacy model, let's preview migrating only the latest edition.
    if legacy_record.is_a?(Document)
      legacy_record = legacy_record.editions.last
    end

    compare_payloads(legacy_record, recipe)
  end

private

  def compare_payloads(legacy_record, recipe)
    # Grab the payloads from the old presenter _before_ we do any mutation, to ensure we're comparing against the original payload
    old_presenter = recipe.new.legacy_presenter.new(legacy_record)
    old_content = old_presenter.content
    old_links = old_presenter.links

    standard_edition = recipe.new.build_edition(legacy_record)
    new_presenter = PublishingApi::StandardEditionPresenter.new(standard_edition)

    <<~OUTPUT
      OLD PAYLOAD
      ===CONTENT
      #{JSON.pretty_generate(old_content)}
      ===LINKS
      #{JSON.pretty_generate(old_links)}

      NEW PAYLOAD
      ===CONTENT
      #{JSON.pretty_generate(new_presenter.content)}
      ===LINKS
      #{JSON.pretty_generate(new_presenter.links)}

      NORMALISED DIFF
      ===TODO: fill this in
    OUTPUT
  end
end
