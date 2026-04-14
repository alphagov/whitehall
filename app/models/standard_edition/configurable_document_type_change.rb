class StandardEdition::ConfigurableDocumentTypeChange
  def initialize(type_conversion, publishing_api_client)
    @conversion = type_conversion
    @client = publishing_api_client
    @presenter = PublishingApi::StandardEditionPresenter.new(@conversion.edition)
  end

  def apply
    result = false
    begin
      @conversion.prepare
      update_publishing_api
      @conversion.convert
      result = true
      update_publishing_api
    rescue
      Rails.logger.log(:error, "Configurable document type conversion failed for edition #{@conversion.edition.content_id}. It is likely that Whitehall and Publishing API are out of sync.")
    ensure
      return result
    end
  end

private

  def update_publishing_api
    @conversion.edition.available_locales.each do |locale|
      I18n.with_locale(locale) do
        @client.put_content(
          @presenter.content_id,
          @presenter.content,
          )
      end
    end

    @client.patch_links(
      @presenter.content_id,
      @presenter.links,
      )
  end
end