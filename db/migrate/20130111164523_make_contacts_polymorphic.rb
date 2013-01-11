class MakeContactsPolymorphic < ActiveRecord::Migration

  # NOTE: This migration requires a further migration to remove
  # organisation_id, which is no longer in use after this code change.

  def change
    add_column :contacts, :contactable_id, :integer
    add_column :contacts, :contactable_type, :string

    execute "UPDATE contacts SET contactable_id = organisation_id, contactable_type = 'Organisation'"
  end
end
