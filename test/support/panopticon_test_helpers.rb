module PanopticonTestHelpers
  def stub_panopticon_registration(edition)
    Whitehall.stubs(:register_edition_with_panopticon).with(edition)
  end
end
