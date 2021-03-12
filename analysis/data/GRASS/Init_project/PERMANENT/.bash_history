r.in.gdal input=E:\repRCHrs\analysis\data\dtm2014\TEST_AREA\3dm_32482_5618_1_he_xyzirnc_ground_IDW01.tif output=test_area
r.in.gdal input=E:\repRCHrs\analysis\data\dtm2014\TEST_AREA\3dm_32482_5618_1_he_xyzirnc_ground_IDW01.tif output=test_area
g.extension extension=r.local.relief
r.local.relief
r.local.relief -i --overwrite --verbose input=test_area@PERMANENT output=test_area_LRM neighborhood_size=3
r.local.relief input=test_area@PERMANENT output=test_area_LRM
r.local.relief
r.local.relief input=test_area@PERMANENT output=LRM
