class SupersedingRoleAssociation < ActiveRecord::Base
  self.table_name = "role_supersedings"
  belongs_to :superseding_role, class_name: "Role", foreign_key: "superseding_role_id"
  belongs_to :superseded_role, class_name: "Role", foreign_key: "superseded_role_id"
end
