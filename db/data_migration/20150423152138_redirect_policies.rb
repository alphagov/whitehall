require "csv"
require 'gds_api/router'
router_api = GdsApi::Router.new(Plek.current.find('router-api'))

csv_file = File.join(File.dirname(__FILE__), "20150423152138_redirect_policies.csv")

csv = CSV.parse(File.open(csv_file), headers: true)

csv.each do |row|
  puts "Redirecting #{row["Source"]}"
  router_api.add_redirect_route(row["Source"], 'exact', row["Destination"], 'temporary', skip_commit: true)
end
router_api.commit_routes
