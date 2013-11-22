class RemoveOrganisationIdFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :organisation_id
  end

  def down
    add_column :users, :organisation_id, :integer
    add_index :users, :organisation_id

    execute %{
      UPDATE users u JOIN organisations o ON u.organisation_slug = o.slug
      SET u.organisation_id = o.id
    }
  end
end
