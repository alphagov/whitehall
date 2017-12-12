module AssetManagerTestHelpers
  def file_and_legacy_url_path_matching(regex)
    all_of(
      has_entry(:file, instance_of(File)),
      has_entry(:legacy_url_path, regexp_matches(regex))
    )
  end
end
