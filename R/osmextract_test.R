oe_providers()
class(geofabrik_zones)
library(sf)

par(mar = rep(0.1, 4))
plot(st_geometry(geofabrik_zones))

oe_match("Hessen", quiet = TRUE)
#$url
#[1] "https://download.geofabrik.de/europe/germany/hessen-latest.osm.pbf"

#$file_size
#[1] 238807398

oe_match_pattern("Hessen", provider = "geofabrik")
#[1] "Hessen"

oe_match_pattern("Hessen",  full_row = TRUE)[, 1:3]
#Simple feature collection with 1 feature and 3 fields
#geometry type:  MULTIPOLYGON
#dimension:      XY
#bbox:           xmin: 7.768021 ymin: 49.39321 xmax: 10.24595 ymax: 51.65916
#geographic CRS: WGS 84
#id   name  parent                       geometry
#138 hessen Hessen germany MULTIPOLYGON (((9.041576 49...
