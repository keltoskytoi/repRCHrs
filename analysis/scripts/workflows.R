#Workflow Freeland et al 2016

mermaid("
sequenceDiagram
  DTM->>fDTM: mean filter
  fDTM->>ifDTM: invert raster
  ifDTM->>pf ifDTM: fill pits
  Note right of ifDTM: Wang & Liu 2006
  pf ifDTM->>diff ifDTM: ifDTM-pf ifDTM
  diff ifDTM->> possible barrows: morphometric rules
  Note right of diff ifDTM: e.g. c=(4piArea)/perimeter2
")

mermaid("graph TB;
A[DTM] -->|mean filter| B(fDTM)
B -->|invert raster| C(ifDTM)
C -->|fill pits: Wang&Liu 2006| D(pf ifDTM)
D -->|ifDTM-pf ifDT| E(diff ifDTM)
E -->|morphometric rules| F(possible barrows)
")

#Workflow Davis et al 2019
mermaid("
sequenceDiagram
  DTM->>iDTM: invert raster
  Note left of iDTM: (((x - max(x)) * -1) + min(x)
  Note left of deprMaps: uses Monte Carlo Simulation to map depressions
  ifDTM->>deprMaps: SDA Whitebox GAT - multiple versions
  deprMaps->>fdeprMaps: size filter
  fdeprMaps->>possible barrows: comparsion to lu maps
")

mermaid("graph TB;
A[DTM] -->|inverraster| B(iDTM)
B -->|SDA Whitebox GAT: MC simulation| C(deprMap)
C -->|size filter| D(fdeprMaps)
D -->|comparision with lu maps| E(possible barrows)
")


#Workflow Rom et al 2020
mermaid("
sequenceDiagram
  DTM->>fDTM: lowpass filter
  fDTM->>ifDTM: invert raster
  ifDTM->>pf ifDTM: fill pits
  Note right of ifDTM: Wang & Liu 2006 Whitebox GAT
  pf ifDTM->>diff ifDTM: ifDTM-pf ifDTM
  diff ifDTM->> thresh diff ifDTM: thresholds
  Note right of diff ifDTM: min hieght, max area
  thresh diff ifDTM->>possible barrows: invert raster
")

mermaid("graph TB;
A[DTM] -->|mean filter| B(fDTM)
B -->|invert raster| C(ifDTM)
C -->|fill pits: Wang&Liu 2006| D(pf ifDTM)
D -->|ifDTM-pf ifDT| E(diff ifDTM)
E -->|morphometric rules| F(possible barrows)
")


#Workflow of the thesis
mermaid("
sequenceDiagram
  DTM->>fDTM: filter raster::focal, fun=mean
  fDTM->>ifDTM: spatialEco::raster.invert
  ifDTM->>pf ifDTM: fill pits RSAGA::rsaga.geoprocessor module 4
  pf ifDTM->>diff ifDTM: ifDTM-pf ifDTM
  diff ifDTM->> rcl diff ifDTM: recalss & thresholds
  rcl diff ifDTM->> possible barrows: spatialEco::raster.invert
")

mermaid("graph TB;
A[DTM] -->|filter raster::focal, fun=meant| B(fDTM)
B -->|spatialEco::raster.invert| C(ifDTM)
C -->|fill pits RSAGA::rsaga.geoprocessor module 4| D(pf ifDTM)
D -->|ifDTM-pf ifDT| E(diff ifDTM)
E -->|recalss&thresholds| F(rcl diff ifDTM)
F -->|spatialEco::raster.invert| G{possible barrows}
")

