module ObjectStore
  class ContentBlockPresenter
    delegate :title,
             :properties,
             :bock_type,
             to: :content_block

    def initialize(model, **)
      puts "block type is"
      puts model.block_type
      @content_block = model
    end

    def content
      {
        title:,
        properties:,
        block_type:,
      }
    end

    def links
      {}
    end

  private

    attr_reader :content_block
  end
end
