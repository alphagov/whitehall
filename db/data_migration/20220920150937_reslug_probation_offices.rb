slug_changes = [
  {
    slug: "kirklees-kirklees-probation-centre",
    new_slug: "kirklees-dewsbury-probation-office",
  },
  {
    slug: "hambleton-essex-lodge",
    new_slug: "hambleton-northallerton-probation-office",
  },
  {
    slug: "hertfordshire-hereford-probation-office",
    new_slug: "herefordshire-hereford-probation-office",
  },
  {
    slug: "lincolnshire-the-town-hall",
    new_slug: "lincolnshire-skegness-probation-office",
  },
  {
    slug: "lincolnshire-grange-house",
    new_slug: "lincolnshire-grantham-probation-office",
  },
  {
    slug: "derbyshire-derbyshire-probation-office",
    new_slug: "derbyshire-ilkeston-probation-office",
  },
  {
    slug: "derbyshire-chesterfield-house",
    new_slug: "derbyshire-buxton-probation-office",
  },
  {
    slug: "cheltenham-cheltenham-probation-office",
    new_slug: "gloucestershire-cheltenham-probation-office",
  },
  {
    slug: "torbay-thurlow-house",
    new_slug: "torbay-torquay-probation-office",
  },
  {
    slug: "forest-of-dean-the-court-house",
    new_slug: "forest-of-dean-coleford-probation-office",
  },
  {
    slug: "south-somerset-yeovil-probation-office",
    new_slug: "south-somerset-yeovil-probation-office",
  },
  {
    slug: "gloucester-twyver-house",
    new_slug: "gloucester-gloucester-probation-office",
  },
  {
    slug: "north-devon-kingsley-house",
    new_slug: "north-devon-barnstaple-probation-office",
  },
  {
    slug: "avon-avon-probation-office",
    new_slug: "avon-bath-probation-office",
  },
  {
    slug: "somerset-riverside-house",
    new_slug: "somerset-bridgwater-probation-office",
  },
  {
    slug: "north-devon-endsleigh-house",
    new_slug: "north-devon-camborne-probation-office",
  },
  {
    slug: "salisbury-the-boulter-centre",
    new_slug: "salisbury-salisbury-probation-office",
  },
  {
    slug: "plymouth-st-catherines-house",
    new_slug: "plymouth-plymouth-probation-office",
  },
  {
    slug: "somerset-west-and-taunton-taunton-probation-office",
    new_slug: "somerset-taunton-probation-office",
  },
  {
    slug: "swindon-centenary-house",
    new_slug: "swindon-swindon-probation-office",
  },
  {
    slug: "torquay-union-house",
    new_slug: "torquay-bay-house",
  },
  {
    slug: "county-durham-durham-house",
    new_slug: "county-durham-peterlee-probation-office",
  },
  {
    slug: "county-durham-framwell-house",
    new_slug: "county-durham-durham-city-probation-office",
  },
  {
    slug: "blackburn-with-darwen-blackburn-probation-office",
    new_slug: "blackburn-with-darwen-40b-preston-new-road",
  },
  {
    slug: "lancashire-chapel-house",
    new_slug: "lancashire-skelmersdale-probation-office",
  },
  {
    slug: "blackpool-113-coronation-street",
    new_slug: "blackpool-113-coronation-street",
  },
  {
    slug: "northamptonshire-northamptonshire-probation-office",
    new_slug: "northamptonshire-wellingborough-probation-office",
  },
  {
    slug: "luton-frank-lord-house",
    new_slug: "luton-luton-probation-office",
  },
  {
    slug: "cambridgeshire-godwin-house",
    new_slug: "cambridgeshire-huntingdon-probation-office",
  },
  {
    slug: "thanet-darlincton-house",
    new_slug: "thanet-darrington-house",
  },
  {
    slug: "southwark-mitre-house",
    new_slug: "southwark-mitre-house-great-dover-street",
  },
  {
    slug: "tower-hamlets-337-cambridge-heath-road",
    new_slug: "tower-hamlets-377-cambridge-heath-road",
  },
  {
    slug: "haringey-haringey-probation-office",
    new_slug: "haringey-lansdowne-road-probation-office",
  },
]

slug_changes.each do |slug_change|
  document = Document.find_by(slug: slug_change[:slug])

  edition = document.live_edition
  Whitehall::SearchIndex.delete(edition)

  document.update!(slug: slug_change[:new_slug])

  PublishingApiDocumentRepublishingWorker.new.perform(document.id)

  Whitehall::SearchIndex.add(edition)
end
