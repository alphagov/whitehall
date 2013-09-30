class DocumentCollectionPresenter
  def initialize(document_collection, view_context, opts = {})
    @view_context = view_context
    @group_presenter_klass = opts[:groups_presented_by] || DocumentCollectionGroupPresenter
    @document_collection = document_collection
  end

  def title
    document_collection.title
  end

  def summary
    document_collection.summary
  end

  def body
    document_collection.body
  end

  def groups
    document_collection.groups.visible.map { |group| @group_presenter_klass.new(group, @view_context) }
  end

  private

  attr_reader :document_collection
end
