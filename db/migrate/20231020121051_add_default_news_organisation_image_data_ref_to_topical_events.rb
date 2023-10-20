class AddDefaultNewsOrganisationImageDataRefToTopicalEvents < ActiveRecord::Migration[7.0]
  def change
    add_reference :topical_events, :default_news_organisation_image_data, index: true
  end
end
