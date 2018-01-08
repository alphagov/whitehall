class AddHomepageTypeToOrganisation < ActiveRecord::Migration
  class FeaturedServicesAndGuidance < ApplicationRecord
    self.table_name = :featured_services_and_guidance
  end

  def up
    add_column :organisations, :homepage_type, :string, default: 'news'

    orgs_with_featured_services_and_guidance = FeaturedServicesAndGuidance.where("linkable_type='Organisation'").group('linkable_id').map(&:linkable_id)

    Organisation.where(id: orgs_with_featured_services_and_guidance).update_all(homepage_type: 'service')
  end

  def down
    remove_column :organisations, :homepage_type
  end
end
