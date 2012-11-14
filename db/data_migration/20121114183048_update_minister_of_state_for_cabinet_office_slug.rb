role = Role.find_by_slug!("minister-of-state-schools")
role.update_attribute :slug, role.name.parameterize
