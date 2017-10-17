role_to_delete = "minister-of-state--41"
redirect_path = "/government/ministers/minister-of-state-employment"

role = Role.find_by!(slug: role_to_delete)

role.role_appointments = []
role.organisations = []
role.worldwide_organisations = []
role.save!
role.destroy

raise "Failed to delete role" if Role.find_by(slug: role_to_delete)

Whitehall::SearchIndex.delete(role)

PublishingApiRedirectWorker.new.perform(role.content_id, redirect_path, "en")
PublishingApiRedirectWorker.new.perform(role.content_id, "#{redirect_path}.cy", "cy")
