class AddOrganisationSlugToUsers < ActiveRecord::Migration
  def up
    # Make the existing organisations.slug column not null
    change_column :organisations, :slug, :string, null: false

    # ... and unique
    remove_index :organisations, :slug
    add_index :organisations, :slug, unique: true

    add_column :users, :organisation_slug, :string
    add_index :users, :organisation_slug

    execute %{
      UPDATE users u JOIN organisations o ON u.organisation_id = o.id
      SET u.organisation_slug = o.slug
    }
  end

  def down
    remove_index :users, :organisation_slug
    remove_column :users, :organisation_slug

    remove_index :organisations, :slug
    add_index :organisations, :slug, unique: false

    change_column :organisations, :slug, :string, null: true
  end
end
