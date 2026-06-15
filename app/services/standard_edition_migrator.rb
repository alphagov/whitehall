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

  def compare_payloads(_legacy_record, _recipe)
    "TODO: Implement payload comparison logic here"
  end
end
