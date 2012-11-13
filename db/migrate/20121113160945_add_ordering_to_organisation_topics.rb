class AddOrderingToOrganisationTopics < ActiveRecord::Migration
  def up
    add_column :organisation_topics, :ordering, :integer
    add_index :organisation_topics, [:organisation_id, :ordering], unique: true
    execute "update organisation_topics set ordering=id"
  end

  def down
    remove_index :organisation_topics, [:organisation_id, :ordering]
    remove_column :organisation_topics, :ordering
  end
end
