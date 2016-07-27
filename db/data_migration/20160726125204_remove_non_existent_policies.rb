#These records are `Policy` associations for Detailed Guides where the policy
#does no exist in publishing api. As there doesn't seem to be any other way of
#identifying the policies that they relate to we may as well tidy them up
#
#433102,/guidance/being-inspected-as-a-childrens-centre-guidance-for-providers
#  ["5d646277-7631-11e4-a3cb-005056011aef"] not in publishing api
#441050,/guidance/fashion-and-textiles-technical-apprenticeships
#  ["6053a0e7-7631-11e4-a3cb-005056011aef"] not in publishing api
#480715,/guidance/being-inspected-as-a-boarding-andor-residential-school
#  ["5d646277-7631-11e4-a3cb-005056011aef"] not in publishing api

EditionPolicy.where(edition_id: [433102, 441050, 480715]).destroy_all
