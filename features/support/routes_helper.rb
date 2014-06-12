module PublicHostHelper
  def public_url(path)
    (Plek.new.website_uri + path).to_s
  end
end

World(Admin::EditionRoutesHelper)
World(PublicDocumentRoutesHelper)
World(PublicHostHelper)
