class PlanForChangeLandingPage::BlockFactory
  def self.build_all(blocks, images)
    (blocks || []).map { build(_1, images) }
  end

  def self.build(block, images)
    case block.with_indifferent_access
    in { type: "box" }
      PlanForChangeLandingPage::CompoundBlock.new(block, images, "box_content")
    in { type: "card" }
      PlanForChangeLandingPage::CompoundBlock.new(block, images, "card_content")
    in { type: "featured" }
      PlanForChangeLandingPage::FeaturedBlock.new(block, images)
    in { type: "hero" }
      PlanForChangeLandingPage::HeroBlock.new(block, images)
    in { type: "image" }
      PlanForChangeLandingPage::ImageBlock.new(block, images)
    in { type: String, blocks: Array }
      PlanForChangeLandingPage::ParentBlock.new(block, images)
    else
      PlanForChangeLandingPage::BaseBlock.new(block, images)
    end
  end
end
