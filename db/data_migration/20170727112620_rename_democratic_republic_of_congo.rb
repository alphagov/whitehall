# Change country name from Democratic Republic of Congo to
# Democratic Republic of the Congo
WorldLocation
  .find_by(slug: "democratic-republic-of-the-congo")
  .translation
  .update(name: "Democratic Republic of the Congo")
