if policy = Document.find_by_slug("stimulating-private-sector-investment-to-create-the-best-broadband-network-in-europe-by-2015")
  policy.update_column(:slug, 'transforming-uk-broadband')
end
