module StandardEdition::ChildDocuments
  extend ActiveSupport::Concern

  def allows_child_documents?
    type_instance.child_documents
  end

  def child_documents
    []
  end
end
