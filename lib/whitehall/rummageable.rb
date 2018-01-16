require 'benchmark'
require 'json'
require 'multi_json'
require 'null_logger'
require 'rest_client'

module Whitehall
  module Rummageable
    class Index
      def initialize(base_url, index_name, options = {})
        @index_url = [base_url, index_name.sub(%r{^/}, '')].join('/')
        @logger = options[:logger] || NullLogger.instance
        @batch_size = options.fetch(:batch_size, 20)
        @retry_delay = options.fetch(:retry_delay, 2)
        @attempts = options.fetch(:attempts, 3)
      end

      def add(entry)
        repeatedly do
          make_request(:post, documents_url, MultiJson.encode([entry]))
        end
      end

      def add_batch(entries)
        entries.each_slice(@batch_size) do |batch|
          repeatedly do
            make_request(:post, documents_url, MultiJson.encode(batch))
          end
        end
      end

      def amend(link, changes)
        repeatedly do
          make_request(:post, documents_url(link: link), changes)
        end
      end

      def delete(id, options = {})
        type = options[:type] || 'edition'
        repeatedly do
          make_request(:delete, documents_url(id: id, type: type))
        end
      end

      def delete_all
        repeatedly do
          make_request(:delete, documents_url + '?delete_all=1')
        end
      end

      def commit
        repeatedly do
          make_request(:post, [@index_url, 'commit'].join('/'), MultiJson.encode({}))
        end
      end

    private

      def repeatedly
        @attempts.times do |i|
          begin
            return yield
          rescue RestClient::RequestFailed, RestClient::RequestTimeout, RestClient::ServerBrokeConnection => e
            @logger.warn e.message
            raise if @attempts == i + 1
            @logger.info 'Retrying...'
            sleep(@retry_delay) if @retry_delay
          end
        end
      end

      def log_request(method, url, _payload = nil)
        @logger.info("Rummageable request: #{method.upcase} #{url}")
      end

      def log_response(method, url, call_time, response)
        time = sprintf('%.03f', call_time)
        result = response.length.positive? ? JSON.parse(response).fetch('result', 'UNKNOWN') : "UNKNOWN"
        @logger.info("Rummageable response: #{method.upcase} #{url} - time: #{time}s, result: #{result}")
      end

      def make_request(method, *args)
        response = nil
        log_request(method, *args)
        call_time = Benchmark.realtime do
          response = RestClient.send(method, *args, content_type: :json, accept: :json)
        end
        log_response(method, args.first, call_time, response)
        response
      end

      def documents_url(options = {})
        options[:id] ||= options[:link]

        parts = [@index_url, 'documents']
        parts << CGI.escape(options[:type]) if options[:type]
        parts << CGI.escape(options[:id]) if options[:id]
        parts.join('/')
      end
    end
  end
end
