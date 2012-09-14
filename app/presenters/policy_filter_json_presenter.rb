class PolicyFilterJsonPresenter < DocumentFilterJsonPresenter

  def document_hash(document)
    super.merge(
      first_published_at: h.render_datetime_microformat(document, :first_published_at) {
        document.first_published_at.to_s(:long_ordinal)
      }.html_safe
    )
  end
end
