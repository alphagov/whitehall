require "policy_admin_url_replacer"

PolicyAdminURLReplacer.replace_in!(Edition.where(state: Edition::PUBLICLY_VISIBLE_STATES + Edition::PRE_PUBLICATION_STATES))
