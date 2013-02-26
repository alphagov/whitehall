category = MainstreamCategory.create(
  title: "Applying for government graduate schemes",
  slug: "Applying for government graduate schemes".parameterize,
  description: "Information about government graduate schemes and guidance on how to apply.",
  parent_tag: "working/finding-job",
  parent_title: "Finding a job"
)

if category
  puts "Mainstream category '#{category.title}' created"
end
