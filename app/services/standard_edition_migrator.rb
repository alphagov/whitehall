class StandardEditionMigrator
  def self.preview_migration(...)
    new.preview_migration(...)
  end

  def self.diff_content_payloads(...)
    new.diff_content_payloads(...)
  end

  def self.diff_links_payloads(...)
    new.diff_links_payloads(...)
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

  def diff_content_payloads(recipe:, old_content: nil, new_content: nil)
    diff_values(
      recipe.ignore_legacy_content_fields(old_content.deep_dup),
      recipe.ignore_new_content_fields(new_content.deep_dup),
    ).to_s
  end

  def diff_links_payloads(recipe:, old_links: nil, new_links: nil)
    diff_values(
      recipe.ignore_legacy_links(old_links.deep_dup),
      recipe.ignore_new_links(new_links.deep_dup),
    ).to_s
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
      ===CONTENT
      #{diff_content_payloads(
        old_content: old_content,
        new_content: new_presenter.content,
        recipe: recipe.new,
      )}
      ===LINKS
      #{diff_links_payloads(
        old_links: old_links,
        new_links: new_presenter.links,
        recipe: recipe.new,
      )}
    OUTPUT
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
