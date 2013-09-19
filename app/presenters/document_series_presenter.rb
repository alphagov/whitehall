class DocumentSeriesPresenter
  def initialize(document_series, view_context, opts = {})
    @view_context = view_context
    @group_presenter_klass = opts[:groups_presented_by] || DocumentSeriesGroupPresenter
    @document_series = document_series
  end

  def title
    document_series.title
  end

  def summary
    document_series.summary
  end

  def body
    document_series.body
  end

  def groups
    document_series.groups.visible.map { |group| @group_presenter_klass.new(group, @view_context) }
  end

  private

  attr_reader :document_series
end
