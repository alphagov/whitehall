dupe_slugs = %w(
  /government/publications/weekly-rainfall-and-river-flow-summary-9-to-15-july-2014
  /government/publications/water-situation-report-yorkshire-and-north-east
  /government/publications/weekly-rainfall-and-river-flow-summary-2-to-8-july-2014
  /government/publications/water-situation-report-south-west
  /government/publications/water-situation-report-south-east
  /government/publications/water-situation-report-north-west
  /government/publications/water-situation-report-for-england-june-2014
  /government/publications/water-situation-report-anglian-region
  /government/publications/water-situation-report-midlands
  /government/publications/weekly-rainfall-and-river-flow-summary-25-june-to-1-july-2014
  /government/publications/weekly-rainfall-and-river-flow-summary-18-to-24-june-2014
  /government/publications/weekly-rainfall-and-river-flow-summary-11-to-17-june-2014
  /government/publications/weekly-rainfall-and-river-flow-summary-4-to-10-june-2014
  /government/publications/water-situation-report-for-england-may-2014
  /government/publications/weekly-rainfall-and-river-flow-summary-28-may-to-3-june-2014
  /government/publications/weekly-rainfall-and-river-flow-summary-21-to-27-may-2014
  /government/publications/weekly-rainfall-and-river-flow-summary-14-to-20-may-2014
  /government/publications/weekly-rainfall-and-river-flow-summary-7-to-13-may-2014
  /government/publications/water-situation-report-for-england-april-2014
  /government/publications/weekly-rainfall-and-river-flow-summary-30-april-to-6-may-2014
  /government/publications/weekly-rainfall-and-river-flow-summary-23-to-29-april-2014
  /government/publications/weekly-rainfall-and-river-flow-summary-16-to-22-april-2014
  /government/publications/weekly-rainfall-and-river-flow-summary-9-to-15-april-2014
  /government/publications/water-situation-report-for-england-march-2014
  /government/publications/weekly-rainfall-and-river-flow-summary-2-april-to-8-april-2014
  /government/publications/weekly-rainfall-and-river-flow-summary-26-march-to-1-april-2014
  /government/publications/weekly-rainfall-and-river-flow-summary-19-to-25-march-2014
  /government/publications/water-situation-report-for-england-february-2014
  /government/publications/water-situation-report-for-england-january-2014
  /government/publications/water-situation-report-for-england-december-2013
  /government/publications/water-situation-report-for-england-november-2013
  /government/publications/water-situation-report-for-england-october-2013
  /government/publications/water-situation-report-for-england-september-2013
  /government/publications/water-situation-report-for-england-july-2013
  /government/publications/water-situation-report-for-england-june-2013
  /government/publications/water-situation-report-for-england-may-2013
)

dupe_slugs.each do |slug|
  Rummageable::Index.new(Whitehall::SearchIndex.rummager_host, Whitehall.government_search_index_path).delete(slug)
end
