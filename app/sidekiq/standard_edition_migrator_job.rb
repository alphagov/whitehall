require "diffy"
require "pp"

class StandardEditionMigratorJob < JobBase
  # Don't retry this job if it fails, because it's typically all
  # ‘internal’ – so it won’t fail because a third-party API is down,
  # and any failure is unlikely to resolve itself on a retry.
  sidekiq_options queue: "standard_edition_migration", retry: 0

  def perform(record_id, args)
    republish = args["republish"]
    compare_payloads = args["compare_payloads"]
    model_class_name = args["model_class"]

    if model_class_name != "Document"
      perform_for_non_editionable(record_id, model_class_name, republish:, compare_payloads:)
    else
      perform_for_document(record_id, republish:, compare_payloads:)
    end
  end

private

  def perform_for_document(document_id, republish:, compare_payloads:)
    ActiveRecord::Base.transaction do
      document = Document.find(document_id)
      migrate_editions!(document, compare_payloads)
      document.update_column(:document_type, "StandardEdition")
    end
    PublishingApiDocumentRepublishingJob.new.perform(document_id, true) if republish
  end

  def perform_for_non_editionable(record_id, model_class_name, republish:, compare_payloads:)
    record = model_class_name.constantize.find(record_id)
    recipe = StandardEditionMigrator.recipe_for(record)

    new_document_id = ActiveRecord::Base.transaction do
      migrate_non_editionable!(record, recipe, compare_payloads)
    end

    PublishingApiDocumentRepublishingJob.new.perform(new_document_id, true) if republish
  end

  def migrate_editions!(document, compare_payloads)
    editions_to_migrate = Edition.unscoped.where(document: document)

    editions_to_migrate.each do |edition|
      recipe = StandardEditionMigrator.recipe_for(edition)

      # Skip the payload comparison for superseded or deleted editions
      if compare_payloads && edition.state != "superseded" && !edition.deleted?
        ensure_payloads_remain_identical(edition, recipe) { migrate_edition!(edition, recipe) }
      else
        migrate_edition!(edition, recipe)
      end
    end
  end

  def migrate_non_editionable!(record, recipe, compare_payloads)
    document = Document.create!(document_type: "StandardEdition", content_id: record.content_id)
    edition = StandardEdition.new(
      document:,
      configurable_document_type: recipe.configurable_document_type,
      state: "published",
    )
    edition.save!(validate: false)

    record.translations.each do |record_translation|
      edition.translations.find_or_create_by!(locale: record_translation.locale).update_columns(
        title: recipe.title(record_translation),
        summary: recipe.summary(record_translation),
        block_content: recipe.map_legacy_fields_to_block_content(record, record_translation),
      )
    end

    if compare_payloads
      old_presenter = recipe.presenter.new(record)
      new_presenter = PublishingApi::StandardEditionPresenter.new(edition)
      compare_presenter_payloads(
        old_presenter.content, new_presenter.content,
        old_presenter.links, new_presenter.links,
        recipe, subject: "#{record.class.name} ID #{record.id}"
      )
    end

    document.id
  end

  def migrate_edition!(edition, recipe)
    edition.update_columns(
      type: "StandardEdition",
      configurable_document_type: recipe.configurable_document_type,
    )
    edition.translations.each do |translation|
      translation.update_columns(
        block_content: recipe.map_legacy_fields_to_block_content(translation),
        body: nil, # only applicable to legacy document types
      )
    end
  end

  def ensure_payloads_remain_identical(edition, recipe)
    edition_id = edition.id # capture ID because we can't call `.reload` after updating type

    old_presenter = recipe.presenter.new(edition)
    old_content = old_presenter.content
    old_links = old_presenter.links

    yield

    new_presenter = PublishingApi::StandardEditionPresenter.new(Edition.unscoped.find(edition_id))
    new_content = new_presenter.content
    new_links = new_presenter.links

    compare_presenter_payloads(
      old_content, new_content, old_links, new_links,
      recipe, subject: "Edition ID #{edition.id}"
    )
  end

  def compare_presenter_payloads(old_content, new_content, old_links, new_links, recipe, subject:)
    diff = diff_values(
      recipe.ignore_legacy_content_fields(old_content),
      recipe.ignore_new_content_fields(new_content),
    )
    unless diff.to_s.empty?
      raise "Presenter content mismatch after migration for #{subject}: #{diff}"
    end

    diff = diff_values(
      recipe.ignore_legacy_links(old_links),
      recipe.ignore_new_links(new_links),
    )
    unless diff.to_s.empty?
      raise "Presenter links mismatch after migration for #{subject}: #{diff}"
    end
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
