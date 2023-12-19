Document.where(slug: nil).each do |document|
  document.update_column(:slug, document.id.to_s)
end
