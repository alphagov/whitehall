micronesia = WorldLocation.find_by(slug: "micronesia")
if micronesia
  micronesia.update!(slug: "federated-states-of-micronesia")
  micronesia.translation.update!(name: "Federated States of Micronesia")
end
