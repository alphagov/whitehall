class StandardEditionMigrator::BaseRecipe
  def presenter
    raise NotImplementedError, "Subclasses must implement presenter!"
  end

  def build_edition(record)
    raise NotImplementedError, "Subclasses must implement build_edition!"
  end

  def save_built_edition!
    raise NotImplementedError, "Subclasses must implement save_built_edition!"
  end

  def save_artefacts!(validate:)
    # This is where the Recipe can handle saving any associated artefacts (e.g. Features, Organisations, etc.).
    @artefacts_to_save.each do |artefact|
      # Translations need to be associated with the edition before they can be saved
      if artefact.respond_to?(:edition_id=)
        artefact.edition_id = @edition.id
      end
      artefact.save!(validate: validate)
    end
  end

  # The below methods aren't used in Edition creation - they're used only for payload normalisation for comparison purposes

  def ignore_legacy_content_fields(content)
    # Noop
    content
  end

  def ignore_new_content_fields(content)
    # Noop
    content
  end

  def ignore_legacy_links(links)
    # Noop
    links
  end

  def ignore_new_links(links)
    # Noop
    links
  end
end
