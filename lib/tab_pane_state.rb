class TabPaneState
  def initialize(rendering_context)
    @first_pane = true
    @context = rendering_context
  end

  def pane(options = {}, &blk)
    tag_options = options.merge(class: classes(options[:class]))
    @context.content_tag(:section, tag_options, &blk)
  end

private

  def classes(extra_classes = nil)
    ["tab-pane"].tap { |tab_classes|
      tab_classes << "active" if @first_pane
      @first_pane = false
      tab_classes << extra_classes if extra_classes
    }.join(" ")
  end
end
