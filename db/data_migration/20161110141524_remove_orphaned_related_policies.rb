#This removes related policies that do not exist within the publishing api
EditionPolicy.where(edition_id: 438411, policy_content_id: '5d5e9d5a-7631-11e4-a3cb-005056011aef').first.destroy
EditionPolicy.where(edition_id: 441853, policy_content_id: '5d5ea079-7631-11e4-a3cb-005056011aef').first.destroy
EditionPolicy.where(edition_id: 324040, policy_content_id: '5d3bf7fb-7631-11e4-a3cb-005056011aef').first.destroy
EditionPolicy.where(edition_id: 456453, policy_content_id: '5f52615a-7631-11e4-a3cb-005056011aef').first.destroy
