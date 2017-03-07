require 'gds_api/helpers'
require 'pp'

class UrlToSubscriberListCriteriaMigration
  include GdsApi::Helpers
  class MissingCsvPath < StandardError; end

  attr_reader :csv_path, :perform_migration
  delegate :puts, :print, to: :@out_io

  def initialize(csv_path, perform_migration, out_io = STDOUT)
    @csv_path = csv_path || raise(MissingCsvPath)
    @perform_migration = perform_migration == 'true'

    @parsed = 0
    @skipped = Hash.new(0)
    @missing_lookup = []
    @out_io = out_io
  end

  def run(static_data = UrlToSubscriberListCriteria::BulkStaticData.new)
    CSV.foreach(csv_path, headers: true) do |row|
      url = row['_id']
      parser = UrlToSubscriberListCriteria.new(url, static_data)
      if url =~ %r{/government/policies/.*/activity.atom} # these have already been migrated
        @skipped[:policy_activity] += 1
      elsif url =~ %r{/government/policies.atom} # these have already been migrated
        @skipped[:policy] += 1
      elsif url =~ /official_document_status=/ # to be removed
        @skipped[:official_document_status] += 1
      elsif url =~ /relevant_to_local_government=1/ # to be removed
        @skipped[:relevant_to_local_government] += 1
      elsif url =~ /finder-frontend.production.alphagov.co.uk/
        @skipped[:finder] += 1
      elsif parser.missing_lookup
        @missing_lookup << [parser.missing_lookup, url, row['topic_id']]
      else
        @parsed += 1
        if perform_migration
          migrate(parser, row)
        else
          dry_run(parser, row)
        end
      end
    end
  end

  def migrate(parser, row)
    criteria = parser.convert.merge(
      'gov_delivery_id' => row['topic_id'],
      'created_at' => row['created'],
    )

    response = email_alert_api.find_or_create_subscriber_list(criteria)

    if response['subscriber_list']['gov_delivery_id'] == row['topic_id']
      if Date.parse(response['subscriber_list']['updated_at']) < Date.today
        print '*' # Subscriber list already exists
      else
        print '.'
      end
    else
      # As we are filtering on gov_delivery_id we should not be able to reach here
      # if for any reason we do then something has gone wrong
      puts "******* Error"
      pp criteria
      pp response['subscriber_list']
      pp row.to_h
      return
    end
  end

  def dry_run(parser, row)
    puts "******* GovUkDelivery details"
    puts "Parsing #{row['topic_id']} - #{row['_id']}"

    puts "******* Converted Hash values"
    pp parser.map_url_to_hash
    pp parser.convert

    begin
      criteria = parser.convert.merge('gov_delivery_id' => row['topic_id'])
      response = email_alert_api.send(:search_subscriber_list, criteria)
      puts "******* EmailAlertApi details"
      pp response['subscriber_list']
    rescue GdsApi::HTTPNotFound
      puts "NOT FOUND"
    end

    puts ''
  end

  def report
    puts "" if perform_migration
    puts "#{@parsed} parsed"
    puts "Skipped: #{@skipped}"

    if @missing_lookup.any?
      puts "Missing lookups"
      @missing_lookup.group_by(&:first).each do |field, data|
        puts field
        data.each { |_, url, topic| puts "#{topic} - #{url}" }
        puts ''
      end
    end
  end

  def pp(text)
    # need to overwide the default `pp` method so that we can pass in the output stream to be used.
    PP.pp(text, @out_io)
  end
end
