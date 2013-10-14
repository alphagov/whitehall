# https://www.pivotaltracker.com/story/show/52623285

unwanted_team_emails = "
  'fleet@dsa.gsi.gov.uk',
  'casualsites@dsa.gsi.gov.uk',
  'competition@dsa.gsi.gov.uk',
  'crowncopyright@dsa.gsi.gov.uk',
  'dataprotection@dsa.gsi.gov.uk',
  'ers@dsa.gsi.gov.uk',
  'foi@dsa.gsi.gov.uk',
  'dsaposters@dsa.gsi.gov.uk',
  'pressoffice@dsa.gsi.gov.uk'
"

ActiveRecord::Base.connection.execute "DELETE FROM `policy_group_attachments`
WHERE `policy_group_id` IN (
  SELECT id FROM `policy_groups`
  WHERE `email` IN (#{unwanted_team_emails})
);"

ActiveRecord::Base.connection.execute "DELETE FROM `edition_policy_groups`
WHERE `policy_group_id` IN (
  SELECT id FROM `policy_groups`
  WHERE `email` IN (#{unwanted_team_emails})
);"

ActiveRecord::Base.connection.execute "DELETE FROM `policy_groups` WHERE `email` IN (#{unwanted_team_emails});"
