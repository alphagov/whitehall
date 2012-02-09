require "test_helper"

class CSSAppropriatenessTest < ActiveSupport::TestCase
  test "should not set g1, g2 or g3 classes on non-div elements" do
    matching_lines = `grep -n -I -E 'class="[^"]*g[123]' -r #{Rails.root.join("app/views")}`.split("\n").map { |s| s.split(":").map { |s2| s2.strip } }
    matching_lines.reject! { |(line, number, match)| match =~ /^\<div/ }
    unless matching_lines.empty?
      message = "Some non-div elements have been given grid classes:\n" + matching_lines.map { |x| x.join(":") }.join("\n")
      flunk message
    end
  end
end
