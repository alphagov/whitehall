require "null_logger"

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
          Services.search_api_client.post_json(documents_url, [entry], user_agent: "whitehall (searchable)")
        end
      end

      def add_batch(entries)
        entries.each_slice(@batch_size) do |batch|
          repeatedly do
            Services.search_api_client.post_json(documents_url, batch, user_agent: "whitehall (searchable)")
          end
        end
      end

      def delete(id, options = {})
        type = options[:type] || "edition"
        repeatedly do
          Services.search_api_client.delete_json(documents_url(id:, type:), user_agent: "whitehall (searchable)")
        end
      end

      def delete_all
        repeatedly do
          Services.search_api_client.delete_json("#{documents_url}?delete_all=1", user_agent: "whitehall (searchable)")
        end
      end

      def commit
        repeatedly do
          Services.search_api_client.post_json([@index_url, "commit"].join("/"), {}, user_agent: "whitehall (searchable)")
        end
      end

    private

      def repeatedly
        @attempts.times do |i|
          return yield
        rescue GdsApi::HTTPErrorResponse => e
          @logger.warn e.message
          raise if @attempts == i + 1

          @logger.info "Retrying..."
          sleep(@retry_delay) if @retry_delay
        end
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
