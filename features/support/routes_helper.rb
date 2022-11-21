module PublicHostHelper
  def public_url(path)
    (URI(Plek.website_root) + path).to_s
  end
end

World(Admin::EditionRoutesHelper)
World(PublicDocumentRoutesHelper)
World(PublicHostHelper)
