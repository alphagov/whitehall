class DocumentSeriesGroupPresenter
  def initialize(document_group, view_context, opts = {})
    @view_context = view_context
    @edition_collection_presenter_klass = opts[:edition_collection_presented_by] || EditionCollectionPresenter
    @document_group = document_group
  end

  def id
    document_group.id
  end

  def heading
    document_group.heading
  end

  def body
    document_group.body
  end

  def editions
    @edition_collection_presenter_klass.new(document_group.published_editions, @view_context)
  end

  private

  attr_reader :document_group
end
