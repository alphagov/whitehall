class StandardEditionMigrator::BaseRecipe
  def legacy_presenter
    raise NotImplementedError, "Subclasses must implement legacy_presenter!"
  end

  def build_edition(record)
    raise NotImplementedError, "Subclasses must implement build_edition!"
  end

  def save_artefacts!(validate:)
    # This is where the Recipe can handle saving any associated artefacts (e.g. Features, Organisations, etc.).
    (@artefacts_to_save || []).each do |artefact|
      artefact.save!(validate: validate)
    end
  end

  def queue_for_saving(artefact)
    @artefacts_to_save ||= []
    @artefacts_to_save << artefact
  end

  ###
  # The below methods aren't used in Edition creation - they're used only for payload normalisation for comparison purposes
  ###

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
