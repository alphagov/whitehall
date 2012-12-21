class MakeSocialMediaAccountsPolymorphic < ActiveRecord::Migration
  def up
    change_table("social_media_accounts") do |t|
      t.rename :organisation_id, :socialable_id
      t.string :socialable_type
    end
    execute "update social_media_accounts set socialable_type='Organisation'"
  end

  def down
     change_table("social_media_accounts") do |t|
      t.rename :socialable_id, :organisation_id
      t.remove :socialable_type
    end
  end
end
