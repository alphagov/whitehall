module PanopticonTestHelpers
  def stub_panopticon_registration(edition)
    registerable_edition = RegisterableEdition.new(edition)
    mock_registerer = stub("GdsApi::Panopticon::Registerer")
    mock_registerer.stubs(:register).with(registerable_edition)
    Whitehall.stubs(:panopticon_registerer_for).with(registerable_edition).returns(mock_registerer)
  end
end
