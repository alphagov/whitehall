module SyncChecker
  Failure = Struct.new(:base_path, :status, :document_id, :edition_id, :locale, :content_store, :errors) do
    def initialize(*args)
      super(*args)
      base_path.sub!(%r{^http.*/content}, '')
    end

    def to_s
      each_pair.map { |k,v| "#{k}=#{v}" }.join(" ")
    end

    def to_row
      values.flatten
    end
  end
end
