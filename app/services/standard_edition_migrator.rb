class StandardEditionMigrator
  def self.preview_migration(...)
    new.preview_migration(...)
  end

  def self.perform_migration(...)
    new.perform_migration(...)
  end

  def preview_migration(legacy_record, recipe)
    if legacy_record.is_a?(Edition)
      raise "An Edition was passed. You must pass the Document instead (so that we can migrate all of its Editions)"
    end

    # If passed an Editionable legacy model, let's preview migrating only the latest edition.
    if legacy_record.is_a?(Document)
      legacy_record = legacy_record.editions.last
    end

    edition = recipe.new.build_edition(legacy_record)
    compare_payloads(legacy_record, edition, recipe)
  end

  def perform_migration(legacy_record, recipe)
    ActiveRecord::Base.transaction do
      recipe_instance = recipe.new
      if legacy_record.is_a?(Document)
        editions_to_update = Edition.unscoped.where(document: legacy_record)
        legacy_record.update_column(:document_type, "StandardEdition")
        # Update each edition in-place
        editions_to_update.each do |legacy_edition|
          edition = recipe_instance.build_edition(legacy_edition)
          # Save without validation to get all our ducks in a row
          edition.save!(validate: false)
          recipe_instance.save_artefacts!(validate: false)
          # Then save _with_ validation, now that every interdependent artefact has been created and associated
          edition.save!(validate: true)
          recipe_instance.save_artefacts!(validate: true)
        end
      else
        # TODO: test
        edition.save!(validate: false)
      end
    end
  end

private

  # rubocop:disable Rails/Output
  def compare_payloads(legacy_record, standard_edition, recipe)
    old_presenter = recipe.new.legacy_presenter.new(legacy_record, title: recipe.new.title(legacy_record), update_type: "minor")
    new_presenter = PublishingApi::StandardEditionPresenter.new(standard_edition, update_type: "minor")
    content_diff = diff_payloads(
      old_content: old_presenter.content,
      new_content: new_presenter.content,
      recipe: recipe.new,
    )
    links_diff = diff_payloads(
      old_links: old_presenter.links,
      new_links: new_presenter.links,
      recipe: recipe.new,
    )

    <<~OUTPUT
      OLD PAYLOAD
      ===CONTENT
      #{PP.pp(old_presenter.content, +"")}
      ===LINKS
      #{PP.pp(old_presenter.links, +"")}

      NEW PAYLOAD
      ===CONTENT
      #{PP.pp(new_presenter.content, +"")}
      ===LINKS
      #{PP.pp(new_presenter.links, +"")}

      DIFF
      ===CONTENT
      #{content_diff}
      ===LINKS
      #{links_diff}
    OUTPUT
  end
  # rubocop:enable Rails/Output

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

# class StandardEditionMigrator
#   def initialize(scope:)
#     @scope = scope
#   end

#   def migrate!(compare_payloads: true)
#     @scope.each do |record|
#       StandardEditionMigratorJob.perform_async(
#         record.id,
#         { "compare_payloads" => compare_payloads, "model_class" => model_class_name },
#       )
#     end
#   end

#   def self.recipe_for(model)
#     # if model.is_a?(<FILL ME IN>)
#     #   return YourLegacyDocumentTypeRecipe.new
#     # end

#     if model.is_a?(TopicalEvent)
#       return TopicalEventRecipe
#     end

#     if model.is_a?(Edition)
#       raise "No migration recipe defined for Edition type #{model.type}"
#     end

#     raise "No migration recipe defined for #{model.class.name}"
#   end

#   def preview_migration(legacy_record, recipe, raise_if_payloads_differ: false)
#     edition = recipe.new(legacy_record).build_edition(legacy_record)
#     payloads_unchanged = compare_payloads(legacy_record, edition, recipe)
#     if raise_if_payloads_differ && !payloads_unchanged
#       raise "Payloads diverged in preview for #{legacy_record.class.name} ID #{legacy_record.id}"
#     end
#     edition
#   end





# private

#   def perform_for_document(document_id, compare_payloads:)
#     ActiveRecord::Base.transaction do
#       document = Document.find(document_id)
#       migrate_editions!(document, compare_payloads)
#       document.update_column(:document_type, "StandardEdition")
#     end
#   end

#   def perform_for_non_editionable(record_id, model_class_name, compare_payloads:)
#     record = model_class_name.constantize.find(record_id)
#     recipe = StandardEditionMigrator.recipe_for(record)

#     ActiveRecord::Base.transaction do
#       migrate_non_editionable!(record, recipe, compare_payloads)
#     end
#   end

#   def migrate_editions!(document, compare_payloads)
#     editions_to_migrate = Edition.unscoped.where(document: document)

#     editions_to_migrate.each do |edition|
#       recipe = StandardEditionMigrator.recipe_for(edition).new(document)

#       # Skip the payload comparison for superseded or deleted editions
#       if compare_payloads && edition.state != "superseded" && !edition.deleted?
#         ensure_payloads_remain_identical(edition, recipe) { migrate_edition!(edition, recipe) }
#       else
#         migrate_edition!(edition, recipe)
#       end
#     end
#   end

#   def migrate_non_editionable!(record, recipe, compare_payloads)
#     document = Document.create!(document_type: "StandardEdition", content_id: record.content_id)
#     edition = StandardEdition.new(
#       document:,
#       configurable_document_type: recipe.configurable_document_type,
#       state: "published",
#     )
#     edition.save!(validate: false)

#     recipe.translations.each do |translation|
#       edition.translations.find_or_create_by!(locale: translation.fixed_locale).update_columns(
#         title: recipe.title(translation),
#         summary: recipe.summary(translation),
#         block_content: recipe.map_legacy_fields_to_block_content(record, translation),
#       )
#     end

#     if compare_payloads
#       old_presenter = recipe.presenter.new(record)
#       new_presenter = PublishingApi::StandardEditionPresenter.new(edition)
#       compare_presenter_payloads(
#         old_presenter.content, new_presenter.content,
#         old_presenter.links, new_presenter.links,
#         recipe, subject: "#{record.class.name} ID #{record.id}"
#       )
#     end

#     document.id
#   end

#   def migrate_edition!(edition, recipe)
#     edition.update_columns(
#       type: "StandardEdition",
#       configurable_document_type: recipe.configurable_document_type,
#     )
#     edition.translations.each do |translation|
#       translation.update_columns(
#         block_content: recipe.map_legacy_fields_to_block_content(translation),
#         body: nil, # only applicable to legacy document types
#       )
#     end
#   end

#   def ensure_payloads_remain_identical(edition, recipe)
#     edition_id = edition.id # capture ID because we can't call `.reload` after updating type

#     old_presenter = recipe.presenter.new(edition)
#     old_content = old_presenter.content
#     old_links = old_presenter.links

#     yield

#     new_presenter = PublishingApi::StandardEditionPresenter.new(Edition.unscoped.find(edition_id))
#     new_content = new_presenter.content
#     new_links = new_presenter.links

#     compare_presenter_payloads(
#       old_content, new_content, old_links, new_links,
#       recipe, subject: "Edition ID #{edition.id}"
#     )
#   end

#   def compare_presenter_payloads(old_content, new_content, old_links, new_links, recipe, subject:)
#     diff = diff_values(
#       recipe.ignore_legacy_content_fields(old_content),
#       recipe.ignore_new_content_fields(new_content),
#     )
#     unless diff.to_s.empty?
#       raise "Presenter content mismatch after migration for #{subject}: #{diff}"
#     end

#     diff = diff_values(
#       recipe.ignore_legacy_links(old_links),
#       recipe.ignore_new_links(new_links),
#     )
#     unless diff.to_s.empty?
#       raise "Presenter links mismatch after migration for #{subject}: #{diff}"
#     end
#   end

#   def model_class_name
#     @scope.model.name
#   end

#   def document_scope?
#     model_class_name == "Document"
#   end
# end
