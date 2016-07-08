class PublicDocumentPathSerializer < ActiveModel::Serializer
  attributes :base_path, :routes

  def base_path
    Whitehall.url_maker.public_document_path(object, locale: I18n.locale)
  end

  def routes
    [{ path: base_path, type: "exact" }]
  end
end
