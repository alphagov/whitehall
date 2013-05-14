require 'admin/edition_routes_helper'

module ForceToDraftHOImports
  ADMIN_HOST = 'whitehall-admin.production.alphagov.co.uk'

  def self.routes_helper
    @routes_helper ||= Whitehall::UrlMaker.new(host: ForceToDraftHOImports::ADMIN_HOST)
  end
end

[443, 444].each do |ho_import_id|
  import = Import.find(ho_import_id)
  imported_editions = import.imported_editions.where(state: 'imported')
  puts "Forcing #{imported_editions.count} for Import id: #{ho_import_id} to 'draft'"
  successes = []
  failures = []
  imported_editions.each do |imported_edition|
    begin
      if imported_edition.convert_to_draft!
        successes << imported_edition
      else
        failures << imported_edition
      end
    rescue ActiveRecord::RecordInvalid, Transitions::InvalidTransition
      failures << imported_edition
    end
  end
  puts "Result: #{successes.length} successes, #{failures.length} failures"
  puts "Failures:"
  failures.each do |failed_import|
    puts ForceToDraftHOImports.routes_helper.admin_edition_url(failed_import)
  end
end
