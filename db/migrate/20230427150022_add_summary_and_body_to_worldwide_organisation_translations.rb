class AddSummaryAndBodyToWorldwideOrganisationTranslations < ActiveRecord::Migration[7.0]
  def change
    change_table :worldwide_organisation_translations, bulk: true do |t|
      t.column :summary, :text
      t.column :body, :text
    end
  end
end
