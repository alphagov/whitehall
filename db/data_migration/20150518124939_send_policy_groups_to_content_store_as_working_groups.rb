PolicyGroup.all.each do |policy_group|
  policy_group.publish_to_publishing_api
end
