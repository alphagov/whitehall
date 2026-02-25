module StandardEdition::ChildDocument
  extend ActiveSupport::Concern

  included do
    delegate :parent_editions, to: :document
  end

  def parent_edition
    parent_editions.last
  end

  def is_child_document?
    parent_edition.present?
  end

  def requires_taxon?
    return false if is_child_document?

    super
  end

  def child_document_base_path_override
    if is_child_document?
      parent_path = parent_edition.base_path
      fixed_path = type_instance.settings["fixed_path"]
      fixed_path.sub("$INHERITED", parent_path)
    end
  end
end
