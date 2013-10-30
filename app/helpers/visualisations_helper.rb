module VisualisationsHelper
  def horizontal_percent_bar(fullness)
    fullness = 1.0 if fullness.nan?
    content_tag :div, class: "horizontal-percent-bar" do
      tag :div, class: "bar-inner", style: "width: #{(fullness*100).ceil}%"
    end
  end
end
