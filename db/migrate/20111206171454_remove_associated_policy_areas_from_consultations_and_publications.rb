class RemoveAssociatedPolicyAreasFromConsultationsAndPublications < ActiveRecord::Migration
  def up
    execute %{
      DELETE policy_area_memberships FROM policy_area_memberships 
      INNER JOIN documents ON (documents.id = policy_area_memberships.policy_id)
      WHERE documents.type IN ('Consultation', 'Publication')
    }
  end

  def down
  end
end
