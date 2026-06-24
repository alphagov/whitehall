class StandardEditionMigrator::BaseRecipe
  def legacy_presenter
    raise NotImplementedError, "Subclasses must implement legacy_presenter!"
  end

  def build_edition(record)
    raise NotImplementedError, "Subclasses must implement build_edition!"
  end

  def after_save_edition(_edition, _legacy_record)
    # This is where the Recipe can handle any post-save actions (e.g. creating associations between artefacts).
  end

  def editorial_remark
    "Migrated to StandardEdition"
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
