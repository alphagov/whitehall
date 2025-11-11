require "diffy"
require "pp"

class StandardEditionMigratorWorker < WorkerBase
  # Don't retry this job if it fails, because it's typically all
  # ‘internal’ – so it won’t fail because a third-party API is down,
  # and any failure is unlikely to resolve itself on a retry.
  sidekiq_options queue: "standard_edition_migration", retry: 0

  def perform(document_id, recipe_class_name)
    @recipe = recipe_class_name.constantize.new

    ActiveRecord::Base.transaction do
      document = Document.find(document_id)
      migrate_editions!(document)
      document.update_column(:document_type, "StandardEdition")
    end
  end

private

  def migrate_editions!(document)
    Edition.unscoped.where(document: document).find_each do |edition|
      ensure_payloads_remain_identical(edition) { migrate_edition!(edition) }
    end
  end

  def migrate_edition!(edition)
    edition.update_columns(
      type: "StandardEdition",
      configurable_document_type: @recipe.configurable_document_type,
    )
    edition.translations.each do |translation|
      translation.update_columns(
        block_content: @recipe.map_legacy_fields_to_block_content(edition, translation),
        body: nil, # only applicable to legacy document types
      )
    end
  end

  def ensure_payloads_remain_identical(edition)
    edition_id = edition.id # capture ID because we can't call `.reload` after updating type

    old_presenter = @recipe.presenter.new(edition)
    old_content = old_presenter.content
    old_links = old_presenter.links

    yield

    new_presenter = PublishingApi::StandardEditionPresenter.new(Edition.unscoped.find(edition_id))
    new_content = new_presenter.content
    new_links = new_presenter.links

    diff = diff_values(
      old_content,
      new_content,
    )
    unless diff.to_s.empty?
      raise "Presenter content mismatch after migration for Edition ID #{edition.id}: #{diff}"
    end

    diff = diff_values(
      old_links,
      new_links,
    )
    unless diff.to_s.empty?
      raise "Presenter links mismatch after migration for Edition ID #{edition.id}: #{diff}"
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
