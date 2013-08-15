class AddOrganisationBrandColourToOrganisations < ActiveRecord::Migration
  class OrganisationalRelationship < ActiveRecord::Base
    belongs_to :parent_organisation, class_name: "Organisation"
    belongs_to :child_organisation, class_name: "Organisation"
  end
  class Organisation < ActiveRecord::Base
    has_many :child_organisational_relationships,
              foreign_key: :parent_organisation_id,
              class_name: "OrganisationalRelationship"
    has_many :parent_organisational_relationships,
              foreign_key: :child_organisation_id,
              class_name: "OrganisationalRelationship",
              dependent: :destroy
    has_many :child_organisations,
              through: :child_organisational_relationships
    has_many :parent_organisations,
              through: :parent_organisational_relationships
  end


  def up
    add_column :organisations, :organisation_brand_colour_id, :integer

    Organisation.find_each do |organisation|
      colour = nil
      # First, handle any exceptions to the rule
      case organisation.slug
        when "social-mobility-and-child-poverty-commission", "forestry-commission", "forest-research"

          # No brand colour
          next
        when "export-guarantees-advisory-council"
          colour = OrganisationBrandColour.find("uk-export-finance")
        when "boundary-commission-for-wales"
          colour = OrganisationBrandColour.find("wales-office")
      end

      # Second, see if there is a colour specifically for this org
      if colour.nil?
        begin
          colour = OrganisationBrandColour.find(organisation.slug)
        rescue ActiveRecord::RecordNotFound
        end
      end

      # Finally, try and fill with first parent org
      if colour.nil?
        parent_orgs = organisation.parent_organisations
        if parent_orgs.any?
          begin
            colour = OrganisationBrandColour.find(parent_orgs.first.slug)
          rescue ActiveRecord::RecordNotFound
          end
        end
      end

      unless colour.nil?
        organisation.update_attributes(organisation_brand_colour_id: colour.id)
      end
    end
  end

  def down
    remove_column :organisations, :organisation_brand_colour_id
  end
end
