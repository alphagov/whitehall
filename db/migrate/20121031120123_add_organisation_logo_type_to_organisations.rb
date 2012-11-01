class AddOrganisationLogoTypeToOrganisations < ActiveRecord::Migration
  class Organisation < ActiveRecord::Base
  end

  def up
    # 2 is the id for the single identity crest as described in
    # OrganisationLogoType
    add_column :organisations, :organisation_logo_type_id, :integer, default: 2

    # These have been worked out from the id's given to crests in the
    # ActiveRecordLike class OrganisationLogoType
    department_slug_to_organisation_logo_type_id = {
      'department-for-business-innovation-and-skills' => 3,
      'scotland-office' => 4,
      'home-office' => 5,
      'ministry-of-defence' => 6,
      'wales-office' => 7
    }

    department_slug_to_organisation_logo_type_id.each do |slug, organisation_logo_id|
      execute %{ UPDATE organisations SET organisation_logo_type_id = #{organisation_logo_id} WHERE slug='#{slug}' }
      department_id = Organisation.find_by_slug(slug).id
      execute %{
        UPDATE organisations
        SET organisation_logo_type_id = #{organisation_logo_id}
        WHERE id IN (
          SELECT child_organisation_id
          FROM organisational_relationships
          WHERE parent_organisation_id='#{department_id}'
        )
      }
    end
  end

  def down
    remove_column :organisations, :organisation_logo_type_id
  end
end
