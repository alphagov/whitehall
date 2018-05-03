desc "Publish of the organisations index page to the publishing api. This is called manually when needed."
task publish_organisations_index_page: [:environment] do
  PublishOrganisationsIndexPage.new.publish
end
