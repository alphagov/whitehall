module ContentBlockManager
  class ContentBlock::DiffItem < Data.define(:previous_value, :new_value)
    def self.from_hash(hash)
      hash.with_indifferent_access.map { |key, value|
        if value.key?("new_value") && value.key?("previous_value")
          [key, ContentBlock::DiffItem.new(previous_value: value["previous_value"].presence, new_value: value["new_value"].presence)]
        else
          [key, ContentBlock::DiffItem.from_hash(value)]
        end
      }.to_h
    end
  end
end
