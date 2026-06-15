class StandardEditionMigrator::BaseRecipe
  def legacy_presenter
    raise NotImplementedError, "Subclasses must implement legacy_presenter!"
  end

  def build_edition(record)
    raise NotImplementedError, "Subclasses must implement build_edition!"
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
