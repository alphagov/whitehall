class ConfigurableDocumentTypeConfig
  CONFIG_KEYS = %s(key title description presenters settings)
  def initialize
    @config = {
      "forms" => {},
      "presenters" => {},
      "settings" => {},
    }
  end

  def build(&block)
    instance_eval(&block)
    to_h
  end

  def form(key, &block)
    form = Form.new
    if block_given?
      form.instance_eval(&block)
    end
    @config["forms"][key] = form.to_h
  end

  def schema(&block)
    schema = Class.new(BlockContentSchema)
    if block_given?
      schema.class_eval(&block)
    end
    @config["schema"] = schema.new
  end

  def presenter(key, &block)
    case key
    when "publishing_api"
      presenter = PublishingApiPresenter.new
    else
      raise "Invalid presenter #{key}"
    end

    if block_given?
      presenter.instance_eval(&block)
    end
    @config["presenters"][key] = presenter
  end

  def settings(&block)
    @config["settings"] = block.call
  end

  def respond_to_missing?(symbol, _include_private = false)
    CONFIG_KEYS.include? symbol
  end

  def to_h
    @config
  end

  class Form
    def initialize
      @config = { "fields" => {} }
    end

    def field(key, block_name, attribute_path, &block)
      field = Field.new(block_name, attribute_path)
      if block_given?
        field.instance_eval(&block)
      end
      @config["fields"][key] = field.to_h
    end

    def to_h
      @config
    end
  end

  class Field
    CONFIG_KEYS = %i[title description container size blank_option_label].freeze
    def initialize(block_name, attribute_path)
      @config = {
        "block" => block_name,
        "attribute_path" => attribute_path,
        "required" => false,
        "translatable" => false,
        "experimental" => false,
      }
    end

    def required
      @config["required"] = true
    end

    def translatable
      @config["translatable"] = true
    end

    def experimental
      @config["experimental"] = true
    end

    def options(&block)
      list = SelectOptionList.new
      list.instance_eval(&block)
      @config["options"] = list.to_a
    end

    def respond_to_missing?(symbol, _include_private = false)
      CONFIG_KEYS.include? symbol
    end

    def to_h
      @config
    end

  private

    def method_missing(symbol, *args)
      @config[symbol.to_s] = args.first
    end
  end

  class SelectOptionList
    def initialize
      @options = []
    end

    def respond_to_missing?(_symbol, _include_private = false)
      true
    end

    def to_a
      @options
    end

  private

    def method_missing(symbol, *args)
      raise "options may only have a value and a label" if args.size > 1

      @options << {
        "label": args.first,
        "value": symbol,
      }
    end
  end

  class BlockContentSchema
    include ActiveModel::API
    include ActiveModel::Attributes
    include ActiveModel::Serializers::JSON
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include DateValidation

    delegate :to_h, to: :attributes
  end

  class PublishingApiPresenter
    LINK_TYPES = %i[ministerial_role_appointments organisations topical_events world_locations worldwide_organisation government].freeze
    def initialize
      @details = {}
      @links = []
    end

    def details(edition)
      {}.tap do |output|
        @details.each do |attribute, block|
          output[attribute] = block.call(edition)
        end
      end
    end

    def links(item)
      @links.each_with_object({}) { |link_type, links|
        links.merge!(::PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.public_send(link_type, item))
      }.compact
    end

    def link(link_type)
      if LINK_TYPES.exclude?(link_type)
        raise "Invalid link type #{link_type}"
      end

      @links << link_type
    end

    def respond_to_missing?(_symbol, _include_private = false)
      true
    end

  private

    def method_missing(symbol, *_args, &block)
      raise "presenter attributes must accept a block" unless block_given?

      @details[symbol] = block
    end
  end

private

  def method_missing(symbol, *args)
    @config[symbol.to_s] = args.first
  end
end
