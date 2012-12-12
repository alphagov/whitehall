class AddLeadAndLeadOrderingToOrganisationTopics < ActiveRecord::Migration
  def change
    add_column :organisation_topics, :lead, :boolean, null: false, default: false
    add_column :organisation_topics, :lead_ordering, :integer
  end
end
