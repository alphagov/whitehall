class FixSocialMediaAccountsForWorldwideOrganisations < ActiveRecord::Migration
  # Should have happened in 20130218180301_rename_worldwide_offices_to_worldwide_organisations.rb
  def up
    execute("UPDATE social_media_accounts SET socialable_type = 'WorldwideOrganisation' where socialable_type = 'WorldwideOffice'")
  end

  def down
    execute("UPDATE social_media_accounts SET socialable_type = 'WorldwideOffice' where socialable_type = 'WorldwideOrganisation'")
  end
end
