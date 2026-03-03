class ConfigurableContentBlocks::BaseBlock
  attr_reader :edition, :path

  def initialize(edition, config, path)
    @edition = edition
    @config = config
    @path = path
  end

  def title
    @config["title"]
  end

  def hint_text
    @config["description"]
  end

  def required
    @config["required"]
  end

  def value(locale = nil)
    @path.reduce(@edition) do |obj, segment|
      return nil if obj.nil?

      if segment == "block_content"
        obj.public_send(segment, locale)
      elsif obj.is_a?(Hash) || obj.is_a?(Array)
        obj[segment]
      else
        obj.public_send(segment)
      end
    end
  end

  def primary_locale_value
    return nil unless @edition.is_translation?

    value(@edition.primary_locale.to_sym)
  end

  def render_in(view_context)
    return "" if @edition.is_translation? && @config["translatable"] == false

    view_context.render template: "admin/configurable_content_blocks/#{template_name}", locals: { block: self }
  end

private

  def template_name
    raise NotImplementedError
  end
end
