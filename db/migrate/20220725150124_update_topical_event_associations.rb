class UpdateTopicalEventAssociations < ActiveRecord::Migration[7.0]
  def up
    OffsiteLink.where(parent_type: "Classification").update_all(parent_type: "TopicalEvent")
    SocialMediaAccount.where(socialable_type: "Classification").update_all(socialable_type: "TopicalEvent")
  end

  def down
    OffsiteLink.where(parent_type: "TopicalEvent").update_all(parent_type: "Classification")
    SocialMediaAccount.where(socialable_type: "TopicalEvent").update_all(socialable_type: "Classification")
  end
end
