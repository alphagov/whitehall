class StandardEdition::ConfigurableDocumentTypeChange
  def initialize(type_conversion, publishing_api_client)
    @conversion = type_conversion
    @client = publishing_api_client
    @presenter = PublishingApi::StandardEditionPresenter.new(@conversion.edition)
  end

  def apply
    @conversion.prepare

    @client.put_content(
      @presenter.content_id,
      @presenter.content,
    )

    @client.patch_links(
      @presenter.content_id,
      @presenter.links,
    )

    @conversion.convert

    @client.patch_links(
      @presenter.content_id,
      @presenter.links,
    )
  end
end