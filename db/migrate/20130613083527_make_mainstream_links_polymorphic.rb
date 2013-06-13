# NOTE: There is a corresponding data migration to add the polymorphic association values
# to the existing mainstream links for organisations and world locations
# A subsequent migration will also be required to drop the join models  that this
# replaces (organisation_mainstream_links and world_location_mainstream_links)
class MakeMainstreamLinksPolymorphic < ActiveRecord::Migration
  def change
    add_column :mainstream_links, :linkable_type, :string
    add_column :mainstream_links, :linkable_id, :integer
    add_index  :mainstream_links, [:linkable_id, :linkable_type]
    add_index  :mainstream_links, :linkable_type
  end
end
