class PopulateLogoTextFromOrgNames < ActiveRecord::Migration
  def up
    update %{
      UPDATE organisations SET organisations.logo_formatted_name = organisations.name
        WHERE organisations.logo_formatted_name IS NULL
    }
  end

  def down
    # intentionally blank space
  end
end
