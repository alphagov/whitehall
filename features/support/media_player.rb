module MediaPlayer
  def assert_video_player_exists
    assert page.has_css?(".player-container .video")
    assert page.has_css?(".player-container .control-bar")
  end
end

World(MediaPlayer)
