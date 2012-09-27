class DetailedGuideFilterJsonPresenter < DocumentFilterJsonPresenter
  def document_hash(document)
    super.merge(
      topics: document.topics.map(&:name).join(", ").html_safe
    )
  end
end
