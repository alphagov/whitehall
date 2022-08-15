slug_changes = {
  "electricity-meter-accuracy-and-billing-disputes" => "electricity-meter-accuracy-and-disputes",
  "gas-meter-accuracy-and-billing-disputes" => "gas-meter-accuracy-and-disputes",
}

slug_changes.each do |old_slug, new_slug|
  document = Document.where(slug: old_slug, document_type: "DetailedGuide").first

  if document
    puts "Changing detailed guide slug #{old_slug} to #{new_slug}"
    Whitehall::SearchIndex.delete(document.live_edition)
    document.update!(slug: new_slug)
    Whitehall::SearchIndex.add(document.live_edition)
  else
    puts "Warning: DetailedGuide with slug '#{old_slug}' not found"
  end
end
