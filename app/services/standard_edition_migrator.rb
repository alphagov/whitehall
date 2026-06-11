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

  def self.enqueue_bulk_migration(...)
    new.enqueue_bulk_migration(...)
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

  # TODO: tests for all of the `save!` calls.
  def create_new_document(legacy_record, recipe, raise_if_payloads_differ: true)
    document = Document.new(document_type: "StandardEdition", content_id: legacy_record.content_id)

    ActiveRecord::Base.transaction do
      recipe_instance = recipe.new
      raise "Cannot pass a Document to create_new_document" if legacy_record.is_a?(Document)

      edition = nil
      compare_payloads_and_raise(legacy_record, recipe_instance, raise_if_payloads_differ) do |maybe_compare_generated_payload|
        edition = recipe_instance.build_edition(legacy_record)
        maybe_compare_generated_payload.call(edition)
      end

      edition.document = document

      create_audit_trail(edition, recipe_instance.editorial_remark) do
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

    document.reload
  end

  # TODO: tests for all of the `save!` calls.
  def migrate_existing_document(legacy_record, recipe, raise_if_payloads_differ: true)
    ActiveRecord::Base.transaction do
      recipe_instance = recipe.new
      raise "Cannot pass a non-Document to migrate_existing_document" unless legacy_record.is_a?(Document)

      editions_to_update = Edition.unscoped.where(document: legacy_record)
      legacy_record.update_column(:document_type, "StandardEdition")
      # Update each edition in-place
      editions_to_update.each do |legacy_edition|
        edition = nil
        compare_payloads_and_raise(legacy_edition, recipe_instance, raise_if_payloads_differ) do |maybe_compare_generated_payload|
          edition = recipe_instance.build_edition(legacy_edition)
          maybe_compare_generated_payload.call(edition)
        end
        # Overwrite the legacy edition's attributes with the new edition's attributes (except for id and document_id, which must be preserved)
        legacy_edition = legacy_edition.becomes!(StandardEdition)
        legacy_edition.assign_attributes(edition.attributes.except("id", "document_id"))
        legacy_edition.auth_bypass_id ||= edition.auth_bypass_id || [] #  can't be null

        create_audit_trail(legacy_edition, recipe_instance.editorial_remark) do
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
    legacy_record.reload
  end

  def enqueue_bulk_migration(legacy_records, recipe_class, migration_method:, raise_if_payloads_differ: true)
    legacy_records.each do |legacy_record|
      StandardEditionMigratorJob.perform_async(
        legacy_record.id,
        {
          "model_class" => legacy_record.class.name,
          "recipe_class" => recipe_class.name,
          "migration_method" => migration_method,
          "raise_if_payloads_differ" => raise_if_payloads_differ,
        },
      )
    end
  end

private

  def create_audit_trail(edition, remark)
    # Whitehall's in-house 'AuditTrail' is used to populate the timeline in the sidebar
    robot_user = User.find_by(name: "Scheduled Publishing Robot")
    AuditTrail.acting_as(robot_user) do
      yield
      EditorialRemark.create!(
        edition: edition,
        body: remark,
        author: robot_user,
        created_at: Time.zone.now,
        updated_at: Time.zone.now,
      )
    end
  end

  def compare_payloads_and_raise(legacy_record, recipe_instance, raise_if_payloads_differ)
    unless raise_if_payloads_differ
      # Noop
      yield ->(_edition) { nil }
      return
    end

    old_presenter = recipe_instance.legacy_presenter.new(legacy_record, update_type: "minor")
    old_content = old_presenter.content
    old_links = old_presenter.links
    compare_generated_payload = lambda do |edition|
      new_presenter = PublishingApi::StandardEditionPresenter.new(edition, update_type: "minor")
      new_content = new_presenter.content
      new_links = new_presenter.links
      diff = diff_payloads(
        recipe: recipe_instance,
        old_content: recipe_instance.ignore_legacy_content_fields(old_content),
        new_content: recipe_instance.ignore_new_content_fields(new_content),
        old_links: recipe_instance.ignore_legacy_links(old_links),
        new_links: recipe_instance.ignore_new_links(new_links),
      )
      if diff != ""
        raise "Payloads diverged between legacy and new presenters:\n#{diff}"
      end
    end
    yield compare_generated_payload
  end

  def compare_payloads(legacy_record, recipe)
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
    # Newlines required otherwise Diffy appends "\\ No newline at end of file" to the output
    left  = "#{JSON.pretty_generate(deep_sort(left_val))}\n"
    right = "#{JSON.pretty_generate(deep_sort(right_val))}\n"
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
