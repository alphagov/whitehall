orphaned_assets_for_deletion = %w[
  5a74c75de5274a3cb28671d3
  5a7f6816ed915d74e33f63bc
  63492cb78fa8f534695f39d1
  5a803c5a40f0b62305b89f9f
  682dcd23b33f68eaba9538f5
  688242c92b6fd60b7c161016
  5ce2b57fe5274a4bf48201aa
  61681d1d8fa8f5297cc02b12
  686fb318fe1a249e937cbf96
  682ee571b33f68eaba953948
  60e733158fa8f50c78eb5e7b
  617bdc31d3bf7f5601cf3168
  5a81808440f0b62302697a77
  6852d5512b367fdd44c15e80
  6882430c9fab8e2e8616103f
  5a8039bc40f0b62302692418
  60acf2b2d3bf7f73793252fc
  60d9e16bd3bf7f7c30482787
  665845197b792ffff71a8530
  686f8a9781dd8f70f5de3d9e
  68501b7f29fb1002010c4ea4
  66b9c859ce1fd0da7b5935e7
  628e8e13d3bf7f1f40ca519f
  687e64a8791bb4d8c309a06f
  5bd31b77e5274a6e33ce6b43
  60d9e225d3bf7f7c2c6ba245
  5af94d81ed915d0df4e8cddb
  68821161901d5f8d471205d2
  620fdd3ed3bf7f4f0981a163
  670cf709366f494ab2e7b7b9
  689bb50a5555fb89cf3f5ed4
  688211d46a7ea0e1ce1d360a
  6862a1b2b466cce1bb121a3c
  5b040020ed915d7ab6da4adf
  6863c74eb466cce1bb121ab5
  60d9e1be8fa8f50abf416ec4
  64b95f6c06f78d000d742669
  657060a2809bc30013308150
  670cf0b5080bdf716392f29e
  665845a1d470e3279dd333ac
  673f23ad4a6dd5b06db95a73
  688211f1f47abf78ca1d360f
  646b65f6382a5100139fc516
  6863c7613464d9c0ad609dad
  687653fb55c4bd0544dcaeb1
  665845e00c8f88e868d33392
  664606a4ae748c43d3793d2a
  60d9e23a8fa8f50ac1ee8aa3
  665845d516cf36f4d63ebbf9
  60d9e2118fa8f50ab966e8cc
  620fdc44e90e0710b73fd433
]

orphaned_assets_for_redirect = %w[
  5a804e3640f0b62305b8a5fe
  5a7f2c9a40f0b6230268de3f
  5a8008d9ed915d74e33f80e4
  5a7572c1e5274a1242c9e652
  5a81970a40f0b62305b8fc56
  5a804179ed915d74e622d62b
  5a7f9b9e40f0b62305b882d7
  5a803f2140f0b62305b8a09e
  5b6426bd40f0b6357323afc6
  5a80f2e9e5274a2e87dbcb95
  5a81900a40f0b62302697fb1
  5a8016bce5274a2e87db7c8e
  5a80a22040f0b62305b8c459
  604dd0bee90e077fe5a7a10c
  5c659e1fe5274a318116c4b7
  5f4e7d46e90e071c70aedcca
  5a82ca7840f0b6230269cb79
  5a7f1f7fed915d74e33f4798
  5a74cef8e5274a3f93b48f78
  62bcb0628fa8f535b5ff0b14
  5a82cea6e5274a2e87dc3144
]

orphaned_assets_for_deletion.each do |asset_manager_id|
  AssetManager::AssetDeleter.call(asset_manager_id)
rescue AssetManager::ServiceHelper::AssetNotFound
  logger.info("Asset #{asset_manager_id} has already been deleted from Asset Manager")
end

orphaned_assets_for_redirect.each do |asset_manager_id|
  redirect_url = AttachmentData.joins(:assets)
                     .where(assets: { asset_manager_id: asset_manager_id })
                     .first
                     .redirect_url

  if redirect_url.blank?
    logger.info("No redirect URL found for asset #{asset_manager_id}, skipping")
    next
  end

  AssetManager::AssetUpdater.call(asset_manager_id, { "redirect_url" => redirect_url })
end
