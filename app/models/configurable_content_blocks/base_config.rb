module ConfigurableContentBlocks::BaseConfig
  def title
    @config["title"]
  end

  def hint_text
    @config["description"]
  end

  def required
    @config["required"]
  end
end
