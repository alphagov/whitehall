PolicyAreaRelation.all.each do |relation|
  if relation.inverse_relation.nil?
    puts "Destroying #{relation.policy_area.name} -> #{relation.related_policy_area.name}"
    relation.destroy
  end
end
