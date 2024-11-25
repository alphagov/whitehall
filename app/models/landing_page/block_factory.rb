class LandingPage::BlockFactory
  def self.build_all(blocks, images)
    (blocks || []).map { build(_1, images) }
  end

  def self.build(block, images)
    LandingPage::BaseBlock.new(block, images)
  end
end
