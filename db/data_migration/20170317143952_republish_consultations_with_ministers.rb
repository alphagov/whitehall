ids = [
  5439,
  50_684,
  50_685,
  77_432,
  77_442,
  79_800,
  80_269,
  80_720,
  83_655,
  4472,
  69_951,
  120_467,
  163_210,
  87_751,
  10_204,
  161_204,
  47_718,
  173_639,
  72_337,
  9869,
  150_940,
  179_554,
  201_661,
  201_929,
  168_817,
  202_666,
  47_925,
  164_815,
  209_853,
  206_968,
  192_481,
  172_125,
  174_696,
  169_304,
  211_448,
  38_572,
  168_483,
  179_355,
  168_790,
  188_231,
  174_379,
  214_908,
  169_123,
  193_102,
  173_215,
  229_398,
  173_628,
  173_033,
  133_590,
  170_734,
  170_734,
  170_734,
  225_915,
  233_193,
  222_028,
  225_510,
  175_906,
  175_906,
  175_906,
  175_906,
  209_358,
  202_373,
  169_431,
  169_431,
  169_431,
  211_777,
  217_487,
  9186,
  226_064,
  229_368,
  221_165,
  225_255,
  255_583,
  253_626,
  256_696,
  210_641,
  262_259,
  170_749,
  210_198,
  201_544,
  265_737,
  254_173,
  269_115,
  268_867,
  273_202,
  226_831,
  247_661,
  248_813,
  248_813,
  241_842,
  241_843,
  241_839,
  241_834,
  255_600,
  251_285,
  249_122,
  252_553,
  246_480,
  242_375,
  277_075,
  277_303,
  216_166,
  229_573,
  229_573,
  232_715,
  227_739,
  227_739,
  252_641,
  215_687,
  201_369,
  266_828,
  268_001,
  273_296,
  251_349,
  266_172,
  265_485,
  217_920,
  239_137,
  276_494,
  271_111,
  281_001,
  281_001,
  253_438,
  267_386,
  229_337,
  264_714,
  267_539,
  252_102,
  273_352,
  173_365,
  246_199,
  287_878,
  287_878,
  279_864,
  268_745,
  268_745,
  268_851,
  269_447,
  246_381,
  290_283,
  300_684,
  279_908,
  262_257,
  272_528,
  272_528,
  303_527,
  302_742,
  283_191,
  282_942,
  252_117,
  310_623,
  311_560,
  311_577,
  289_196,
  274_366,
  289_026,
  289_026,
  289_026,
  297_076,
  301_878,
  316_823,
  302_274,
  301_568,
  315_658,
  282_512,
  300_629,
  242_864,
  296_178,
  243_479,
  243_479,
  243_479,
  288_823,
  288_823,
  283_508,
  324_393,
  324_393,
  306_707,
  317_775,
  315_918,
  313_382,
  322_323,
  321_257,
  306_832,
  307_837,
  341_211,
  324_737,
  342_223,
  342_223,
  342_223,
  342_884,
  342_884,
  328_702,
  344_297,
  341_314,
  341_314,
  308_951,
  324_534,
  340_129,
  346_657,
  341_605,
  321_038,
  351_192,
  353_036,
]
Document.where(id: ids).each do |document|
  PublishingApiDocumentRepublishingWorker
    .perform_async_in_queue("bulk_republishing", document.id)
end