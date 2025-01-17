module ContentBlockManager
  class ContentBlock::Version
    class ChangedField < Data.define(:field_name, :new, :previous)
    end
  end
end
