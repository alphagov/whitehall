class RemoveWorldwideOrganisationPageFields < ActiveRecord::Migration[7.1]
  def change
    remove_columns(:worldwide_organisation_pages, :body, :summary, type: "text")
  end
end
