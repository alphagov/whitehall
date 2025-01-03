require "benchmark"
require "json"
require "multi_json"
require "null_logger"
require "rest_client"

module Whitehall
  module Searchable
    class Index
      def initialize(base_url, index_name, options = {})
        @index_url = [base_url, index_name.sub(%r{^/}, "")].join("/")
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

      def delete(id, options = {})
        type = options[:type] || "edition"
        repeatedly do
          make_request(:delete, documents_url(id:, type:))
        end
      end

      def delete_all
        repeatedly do
          make_request(:delete, "#{documents_url}?delete_all=1")
        end
      end

      def commit
        repeatedly do
          make_request(:post, [@index_url, "commit"].join("/"), MultiJson.encode({}))
        end
      end

    private

      def repeatedly
        @attempts.times do |i|
          return yield
        rescue RestClient::RequestFailed, RestClient::ServerBrokeConnection => e
          @logger.warn e.message
          raise if @attempts == i + 1

          @logger.info "Retrying..."
          sleep(@retry_delay) if @retry_delay
        end
      end

      def log_request(method, url, payload = nil)
        log("Searchable request", method, url, payload)
      end

      def log_response(method, call_time, response, url, payload = nil)
        time = sprintf("%.03f", call_time)
        result = response.length.positive? ? JSON.parse(response).fetch("result", "UNKNOWN") : "UNKNOWN"
        log("Searchable response", method, url, payload, time:, result:)
      end

      def log(message, method, url, payload = nil, fields = {})
        if payload.is_a? Hash
          @logger.info(fields.merge(msg: message, method: method.upcase, url:, slug: payload[:slug], content_id: payload[:content_id]))
        else
          @logger.info(fields.merge(msg: message, method: method.upcase, url:))
        end
      end

      def make_request(method, *args)
        response = nil
        log_request(method, *args)
        call_time = Benchmark.realtime do
          response = RestClient.send(
            method,
            *args,
            content_type: :json,
            accept: :json,
            user_agent: "whitehall (searchable)",
            authorization: "Bearer #{ENV['RUMMAGER_BEARER_TOKEN'] || 'example'}",
          )
        end
        log_response(method, call_time, response, *args)
        response
      end

      def documents_url(options = {})
        options[:id] ||= options[:link]

        parts = [@index_url, "documents"]
        parts << CGI.escape(options[:type]) if options[:type]
        parts << CGI.escape(options[:id]) if options[:id]
        parts.join("/")
      end
    end
  end
end
