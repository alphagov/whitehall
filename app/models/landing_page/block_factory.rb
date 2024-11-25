class LandingPage::BlockFactory
  def self.build_all(blocks)
    (blocks || []).map { build(_1) }
  end

  def self.build(block)
    LandingPage::BaseBlock.new(block)
  end
end
