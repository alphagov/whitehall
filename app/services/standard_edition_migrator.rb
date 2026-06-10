class StandardEditionMigrator
  def self.preview_migration(...)
    new.preview_migration(...)
  end

  def self.create_new_document(...)
    new.create_new_document(...)
  end

  def self.migrate_existing_document(...)
    new.migrate_existing_document(...)
  end

  # TODO: enqueue_bulk_migration method

  def preview_migration(legacy_record, recipe, raise_if_payloads_differ: false)
    if legacy_record.is_a?(Edition)
      raise "An Edition was passed. You must pass the Document instead (so that we can migrate all of its Editions)"
    end

    # If passed an Editionable legacy model, let's preview migrating only the latest edition.
    if legacy_record.is_a?(Document)
      legacy_record = legacy_record.editions.last
    end

    compare_payloads(legacy_record, recipe, raise_if_payloads_differ)
  end

  # TODO: tests for all of the `save!` calls.
  def create_new_document(legacy_record, recipe)
    ActiveRecord::Base.transaction do
      recipe_instance = recipe.new
      raise "Cannot pass a Document to create_new_document" if legacy_record.is_a?(Document)

      document = Document.new(document_type: "StandardEdition", content_id: legacy_record.content_id)
      edition = recipe_instance.build_edition(legacy_record)
      edition.document = document
      # Save without validation to get all our ducks in a row
      edition.save!(validate: false)
      recipe_instance.save_artefacts!(edition: edition, validate: false)
      document.save!(validate: false)
      # Then save _with_ validation, now that every interdependent artefact has been created and associated
      edition.save!(validate: true)
      recipe_instance.save_artefacts!(edition: edition, validate: true)
      document.save!(validate: true)
    end
  end

  # TODO: tests for all of the `save!` calls.
  def migrate_existing_document(legacy_record, recipe)
    ActiveRecord::Base.transaction do
      recipe_instance = recipe.new
      raise "Cannot pass a non-Document to migrate_existing_document" unless legacy_record.is_a?(Document)

      editions_to_update = Edition.unscoped.where(document: legacy_record)
      legacy_record.update_column(:document_type, "StandardEdition")
      # Update each edition in-place
      editions_to_update.each do |legacy_edition|
        edition = recipe_instance.build_edition(legacy_edition)
        # Overwrite the legacy edition's attributes with the new edition's attributes (except for id and document_id, which must be preserved)
        legacy_edition = legacy_edition.becomes!(StandardEdition)
        legacy_edition.assign_attributes(edition.attributes.except("id", "document_id"))
        legacy_edition.auth_bypass_id ||= edition.auth_bypass_id || [] # can't be null
        # Have to cast the legacy edition to a StandardEdition in order to save it to bypass STI
        # Save without validation to get all our ducks in a row
        legacy_edition.save!(validate: false)
        recipe_instance.save_artefacts!(edition: legacy_edition, validate: false)
        # Then save _with_ validation, now that every interdependent artefact has been created and associated
        legacy_edition.save!(validate: true)
        recipe_instance.save_artefacts!(edition: legacy_edition, validate: true)
      end
    end
  end

private

  def compare_payloads(legacy_record, recipe, raise_if_payloads_differ)
    # Grab the payloads from the old presenter _before_ we do any mutation, to ensure we're comparing against the original payload
    old_presenter = recipe.new.legacy_presenter.new(legacy_record, update_type: "minor")
    old_content = old_presenter.content
    old_links = old_presenter.links

    standard_edition = recipe.new.build_edition(legacy_record)
    new_presenter = PublishingApi::StandardEditionPresenter.new(standard_edition, update_type: "minor")

    content_diff = diff_payloads(
      old_content: old_content,
      new_content: new_presenter.content,
      recipe: recipe.new,
    )
    links_diff = diff_payloads(
      old_links: old_links,
      new_links: new_presenter.links,
      recipe: recipe.new,
    )

    if raise_if_payloads_differ && (!content_diff.empty? || !links_diff.empty?)
      raise "Payloads diverged between legacy and new presenters"
    end

    <<~OUTPUT
      OLD PAYLOAD
      ===CONTENT
      #{PP.pp(old_content, +'')}
      ===LINKS
      #{PP.pp(old_links, +'')}

      NEW PAYLOAD
      ===CONTENT
      #{PP.pp(new_presenter.content, +'')}
      ===LINKS
      #{PP.pp(new_presenter.links, +'')}

      DIFF
      ===CONTENT
      #{content_diff}
      ===LINKS
      #{links_diff}
    OUTPUT
  end

  def diff_payloads(recipe:, old_content: nil, new_content: nil, old_links: nil, new_links: nil)
    diff = ""
    if old_content && new_content
      diff += diff_values(
        recipe.ignore_legacy_content_fields(old_content),
        recipe.ignore_new_content_fields(new_content),
      ).to_s
    end

    if old_links && new_links
      diff += diff_values(
        recipe.ignore_legacy_links(old_links),
        recipe.ignore_new_links(new_links),
      ).to_s
    end

    diff
  end

  def diff_values(left_val, right_val)
    left  = PP.pp(deep_sort(left_val), +"") # pretty-print to string for cleaner diff output
    right = PP.pp(deep_sort(right_val), +"")
    Diffy::Diff.new(left, right, context: 5, color: true)
  end

  def deep_sort(obj)
    case obj
    when Hash
      obj.keys.sort.index_with { |k| deep_sort(obj[k]) }
    when Array
      a = obj.map { |v| deep_sort(v) }
      a.sort_by { |v| JSON.generate(v) }
    else
      obj
    end
  end
end
