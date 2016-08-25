module SyncChecker
  LinksCheck = Struct.new(:links_key, :expected_content_ids) do
    attr_reader :content_item

    def call(response)
      failures = []
      if response.response_code == 200
        @content_item = JSON.parse(response.body)
        if run_check?
          if key_should_be_present? && object_at_key.nil?
            failures << "the links key '#{links_key}' is not present"
          else
            failures += check_for_missing_content_ids
            failures += check_for_unexpected_content_ids
          end
        end
      end
      failures.flatten.compact
    end

  private

    def run_check?
      %w(gone redirect).exclude?(content_item["schema_name"])
    end

    def object_at_key
      content_item["links"][links_key]
    end

    def key_should_be_present?
      expected_content_ids.any?
    end

    def response_content_ids
      return [] unless object_at_key
      object_at_key.map { |links| links["content_id"] }
    end

    def check_for_missing_content_ids
      expected_content_ids
        .reject { |content_id| response_content_ids.include?(content_id)}
        .map { |missing_content_id| "#{links_key} should contain '#{missing_content_id}' but doesn't" }
    end

    def check_for_unexpected_content_ids
      response_content_ids
        .reject { |content_id| expected_content_ids.include?(content_id)}
        .map { |unexpected_content_id| "#{links_key} shouldn't contain '#{unexpected_content_id}'" }
    end
  end
end
