Document.where(slug: nil).find_each do |document|
  document.update_column(:slug, document.id.to_s)
end
