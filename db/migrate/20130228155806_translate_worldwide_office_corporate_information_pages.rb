class TranslateWorldwideOfficeCorporateInformationPages < ActiveRecord::Migration
  class CorporateInformationPage < ActiveRecord::Base
    translates :summary, :body
  end

  def up
    CorporateInformationPage.create_translation_table!({
      summary: :text, body: :text
    }, {
      migrate_data: true
    })
  end

  def down
    CorporateInformationPage.drop_translation_table!(migrate_data: true)
  end
end
