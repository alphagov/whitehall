module PublicHostHelper
  def public_host_for_test
    Whitehall.public_host_for(Capybara.default_host.gsub(/https?\:\/\//, ''))
  end
end
World(Admin::EditionRoutesHelper)
World(PublicDocumentRoutesHelper)
World(PublicHostHelper)
