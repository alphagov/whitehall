class CreateSocialMediaAccounts < ActiveRecord::Migration
  class SocialMediaServiceTable < ActiveRecord::Base
    set_table_name :social_media_services
  end
  def change
    create_table :social_media_services, force: true do |t|
      t.string :name
      t.timestamps
    end
    create_table :social_media_accounts, force: true do |t|
      t.references :organisation
      t.references :social_media_service
      t.string :url
      t.timestamps
    end
    %w(Twitter Facebook Youtube Flickr).each do |service_name|
      SocialMediaServiceTable.create!(name: service_name)
    end
  end
end