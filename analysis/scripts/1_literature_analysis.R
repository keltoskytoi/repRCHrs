####################################SHORTCUTS###################################
lsdata <- list.files(file.path(path_data), pattern=".csv")
####################################LOAD DATA################################### 
#ID, full, binary table#### 
literature_full <- read.csv(file.path(path_data, "data_table_1.csv"), header = TRUE, 
                       sep=",")
literature_full <- as.tibble(literature_full)
names(literature_full)
         
#[1] "ID"                        "Reference"                 "Year"                     
#[4] "tell_mounds"               "looting"                   "centuriation"             
#[7] "barrows"                   "archaeological_structures" "landforms"                
#[10] "anthrosols"                "kite_walls"                "circular_ditch_system"    
#[13] "fossil_landscape"          "charcoal_kilns"            "monumental_earthworks"    
#[16] "livestock_enclosures"      "bomb_craters"              "grazing_structures"       
#[19] "charcoal_hearths"          "mound_shell_ring"          "round_houses"             
#[22] "shieling"                  "cairns_mining_pits"        "ridge_furrow"             
#[25] "motte_bailey"              "kettle_hole"                "meanders"                 
#[28] "Ringborg"                  "pottery"                   "celtic_fields"            
#[31] "Qanat_system"              "building"                  "platforms"                
#[34] "aquada"                    "terrain"                   "agricultural_terraces"    
#[37] "Template_matching"         "Geometric.knowledge.based" "GeOBIA_based"             
#[40] "Pixel_based"               "Deep._Learning"             "proprietary"              
#[43] "FOSS"                      "no_information"  

str(literature_full)

#Reference, Year, OOI####
ref_year_OOI <- read.csv(file.path(path_data, "data_table_2.csv"), header = TRUE, sep=",")
ref_year_OOI <- as.tibble(ref_year_OOI)
names(ref_year_OOI)
#[1] "ID"        "Reference" "Year"      "OOI" 

#ID, Reference, Year, Method####
ref_year_method <- read.csv(file.path(path_data, "data_table_3.csv"), header = TRUE, sep=",")
ref_year_method <- as.tibble(ref_year_method)
names(ref_year_method)
#[1] "ID"        "Reference" "Year"      "Method"   

#ID, Reference, Year, Software_type####
ref_year_sw <- read.csv(file.path(path_data, "data_table_4.csv"), header = TRUE, sep=",")
ref_year_sw <- as.tibble(ref_year_sw)
names(ref_year_sw)
#[1] "ID"            "Reference"     "Year"          "Software_type"

################################################################################
#ID, full, binary table#### 
ggplot(data = literature_full) + 
  aes(x = Year) + 
  geom_histogram() + 
  theme_minimal(base_size = 10)+
  labs(y = "Number of studies/ year")


#Reference, Year, OOI####
#extract the year and the OOI
ex <- ref_year_OOI %>%
    select(3:4)

#order the OOI according to year to be plotted right 
ex_ex <- ex %>%
  arrange(Year) %>%   
  mutate(OOI=factor(OOI, levels= (unique(OOI))))

#plot the OOIs!
OOI_ex <- ggplot(data = ex_ex, mapping = aes(x = Year, y = OOI, color = OOI)) +
  geom_point(
             ) +
  ylab(label="") + 
  xlab("Year") +
  scale_color_manual(values=c(
    "darkolivegreen3", "darkkhaki" , "seashell4", "firebrick4",
"darkslategrey", "chartreuse4", "darkgoldenrod", "lightcoral", 
"darkseagreen", "lightpink4", "deepskyblue4", "violetred",
"darkblue", "aquamarine4", "darkorange", "indianred4", 
"brown1", "cyan4", "yellow", "violet", "seagreen3", 
"red", "mistyrose4", "yellowgreen", "palevioletred4", 
"cadetblue", "mediumorchid4", "darkgreen", "gold4", 
"salmon4", "steelblue1", "springgreen1", "black"))
OOI_plot <- test_ex + labs(title= "OOI inverstigated per year") +
  theme(plot.title = element_text(hjust = 0.5, size = 12),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()) +
  scale_x_continuous(breaks = seq(2005, 2020, 1))
plot(OOI_plot)

#ID, Reference, Year, Method####
meth <- ref_year_method %>%
  select(3:4)

#order the OOI according to year to be plotted right 
meth_arr <- meth %>%
  arrange(Year) %>%   
  mutate(Method=factor(Method, levels= (unique(Method))))

#plot the Methods!
meth_ex <- ggplot(data = meth, mapping = aes(x = Year, y = Method, color = Method)) +
  geom_point() +
  ylab(label="") + 
  xlab("Year") +
  scale_color_manual(values=c("darkslategrey", "cadetblue",  
                              "darkgoldenrod","darkseagreen", "deepskyblue4"))
meth_plot <- meth_ex + labs(title= "Methods used per year") +
  theme(plot.title = element_text(hjust = 0.5, size = 12),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()) +
  scale_x_continuous(breaks = seq(2005, 2020, 1))
plot(meth_plot)

#count the methods per year! 
meth_count <- count(ref_year_method, c("Method", "Year"))
#                     Method  Year  freq
#1              Deep Learning 2013    1
#2              Deep Learning 2014    1
#3              Deep Learning 2016    1
#4              Deep Learning 2018    3
#5              Deep Learning 2019    3
#6              Deep Learning 2020    3
#7               GeOBIA-based 2006    1
#8               GeOBIA-based 2007    2
#9               GeOBIA-based 2009    1
#10              GeOBIA-based 2010    2
#11              GeOBIA-based 2012    2
#12              GeOBIA-based 2014    1
#13              GeOBIA-based 2015    2
#14              GeOBIA-based 2016    2
#15              GeOBIA-based 2017    5
#16              GeOBIA-based 2018    3
#17              GeOBIA-based 2019    3
#18              GeOBIA-based 2020    3
#19 Geometric knowledge-based 2006    1
#20 Geometric knowledge-based 2007    1
#21 Geometric knowledge-based 2009    1
#22 Geometric knowledge-based 2010    1
#23 Geometric knowledge-based 2012    1
#24 Geometric knowledge-based 2014    1
#25 Geometric knowledge-based 2015    1
#26 Geometric knowledge-based 2016    2
#27 Geometric knowledge-based 2017    1
#28 Geometric knowledge-based 2018    2
#29 Geometric knowledge-based 2019    4
#30 Geometric knowledge-based 2020    2
#31              Pixel-based  2006    1
#32              Pixel-based  2007    3
#33              Pixel-based  2009    1
#34              Pixel-based  2010    1
#35              Pixel-based  2012    1
#36              Pixel-based  2015    1
#37              Pixel-based  2016    2
#38              Pixel-based  2017    1
#39              Pixel-based  2018    1
#40              Pixel-based  2019    2
#41              Pixel-based  2020    3
#42         Template-matching 2007    1
#43         Template-matching 2014    1
#44         Template-matching 2015    3
#45         Template-matching 2017    1
#46         Template-matching 2018    2
#47         Template-matching 2019    2

ggplot(meth_count, aes(x =  Year, y = Method , fill = Method)) +
  geom_density_ridges(scale =2) +
  theme_ridges() +
  scale_fill_brewer(palette = 4) +
  theme(legend.position = "none")

meth_count_ <- ggplot(data = meth_count, mapping = aes(x = Year, y = freq, color = Method)) +
  geom_line() +
  geom_point()+
  ylab(label="") + 
  xlab("Year") +
  scale_color_manual(values=c("darkslategrey", "cadetblue",  
                              "darkgoldenrod","darkseagreen", "deepskyblue4"))
meth_count_plot <- meth_count_ + labs(title= "Methods used per year") +
  theme(plot.title = element_text(hjust = 0.5, size = 12)) +
  scale_x_continuous(breaks = seq(2005, 2020, 1))
plot(meth_count_plot)

#ID, Reference, Year, Software_type####
soft  <- ref_year_sw %>%
  select(3:4)

soft_arr <- soft %>%
  arrange(Year) %>%   
  mutate(Method=factor(Software_type, levels= rev(unique(Software_type))))

soft_ex <- ggplot(data = soft, mapping = aes(x = Year, y = Software_type, 
                                             color = Software_type)) +
  geom_point() +
  ylab(label="") + 
  xlab("Year") +
  scale_color_manual(values=c("darkslategrey", "cadetblue",  
                              "darkgoldenrod","darkseagreen", "deepskyblue4"))
soft_plot <- soft_ex + labs(title= "Software type used per year") +
  theme(plot.title = element_text(hjust = 0.5, size = 12),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()) +
  scale_x_continuous(breaks = seq(2005, 2020, 1))
plot(soft_plot)

