## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----setup--------------------------------------------------------------------
# # Install if you haven't already
# # install.packages("devtools")
# # devtools::install_github("gortegasolis/geomattR")
# 
# library(geomattR)
# library(terra)

## ----quick_start--------------------------------------------------------------
# # Create a simple polygon (1x1 degree square at equator)
# coords <- cbind(c(0, 0, 1, 1, 0), c(0, 1, 1, 0, 0))
# polygon <- vect(coords, type = "polygon", crs = "EPSG:4326")
# 
# # Calculate all available metrics
# result <- calculate_geometric_attributes(polygon)
# 
# # View the results
# print(result)
# 
# # Or view specific columns
# print(result[, c("area", "perimeter", "compactness")])

## ----size_metrics-------------------------------------------------------------
# # Calculate area and perimeter
# polygon_with_size <- calculate_geometric_attributes(
#   polygon,
#   metrics = c("area", "perimeter", "hole_area", "hole_area_pct")
# )
# 
# # Area in square meters (using geodesic calculations)
# print(polygon_with_size$area)
# 
# # Perimeter in meters
# print(polygon_with_size$perimeter)

## ----shape_metrics------------------------------------------------------------
# # Calculate shape characteristics
# polygon_with_shape <- calculate_geometric_attributes(
#   polygon,
#   metrics = c(
#     "compactness", # Polsby-Popper (0-1, 1=perfect circle)
#     "reock", # Reock compactness
#     "shape_index", # Dimensionless shape complexity
#     "circularity_ratio", # Based on max length
#     "fractaldimension", # Boundary complexity
#     "elongation_rectangle" # mean(long sides) / mean(short sides) from the minimum bounding rectangle
#   )
# )
# 
# # Perfect circle has compactness = 1
# # Irregular shapes have lower values
# print(polygon_with_shape[, c("compactness", "shape_index")])

## ----orientation_metrics------------------------------------------------------
# # Calculate orientation
# polygon_with_orient <- calculate_geometric_attributes(
#   polygon,
#   metrics = c("bearing", "northerness", "ew_length", "ns_length", "maxlength")
# )
# 
# # Bearing: axial orientation of the maximum length line, always measured
# # south to north, so it lies within [-90, 90] (0 = N-S axis, -90/90 = E-W axis)
# print(polygon_with_orient$bearing)
# 
# # Northerness: cosine of bearing (0 = E-W axis, 1 = N-S axis)
# print(polygon_with_orient$northerness)
# 
# # Extents in meters: maximum distances from East to West and North to South
# print(paste("EW Extent:", round(polygon_with_orient$ew_length, 0), "m"))
# print(paste("NS Extent:", round(polygon_with_orient$ns_length, 0), "m"))

## ----complexity_metrics-------------------------------------------------------
# polygon_with_complexity <- calculate_geometric_attributes(
#   polygon,
#   metrics = c("sinuosity", "fractaldimension")
# )
# 
# # Sinuosity: perimeter / max_length (>1 indicates rougher boundary)
# print(polygon_with_complexity$sinuosity)
# 
# # Fractal dimension (FRAGSTATS convention): boundary complexity, approaching
# # 1 for simple square-like shapes and 2 for highly convoluted boundaries
# print(polygon_with_complexity$fractaldimension)

## ----geometry_metrics---------------------------------------------------------
# # Get centroid coordinates and structure info
# polygon_with_geom <- calculate_geometric_attributes(
#   polygon,
#   metrics = c(
#     "decimallongitude",
#     "decimallatitude",
#     "num_holes",
#     "num_polygons"
#   )
# )
# 
# print(polygon_with_geom[, c("decimallongitude", "decimallatitude")])

## ----multiple_polygons--------------------------------------------------------
# # Create multiple polygons
# coords1 <- cbind(c(0, 0, 1, 1, 0), c(0, 1, 1, 0, 0))
# coords2 <- cbind(c(1, 1, 2, 2, 1), c(1, 2, 2, 1, 1))
# 
# poly1 <- vect(coords1, type = "polygon", crs = "EPSG:4326")
# poly2 <- vect(coords2, type = "polygon", crs = "EPSG:4326")
# 
# # Combine into single SpatVector
# polygons <- rbind(poly1, poly2)
# 
# # Calculate metrics for all polygons at once
# results <- calculate_geometric_attributes(
#   polygons,
#   metrics = c("area", "perimeter", "compactness")
# )
# 
# # Results have same row count as input
# print(nrow(results)) # 2
# 
# # All metrics calculated
# print(results[, c("area", "perimeter", "compactness")])

## ----parallel, eval=FALSE-----------------------------------------------------
# library(parallel)
# 
# # Create multiple polygons
# polygons <- rbind(poly1, poly2) # From previous example
# 
# # Set up cluster (two workers here; adjust to your machine's resources)
# cl <- makeCluster(2)
# 
# # Process in parallel using the main function
# results <- calculate_geometric_attributes(
#   polygons,
#   metrics = "all",
#   cl = cl
# )
# 
# # Clean up
# stopCluster(cl)
# 
# # Results should be equivalent to sequential processing
# # (allowing for tiny floating-point differences)
# print(head(results))

## ----crs_handling-------------------------------------------------------------
# # Create polygon in geographic CRS (WGS84/EPSG:4326)
# poly_geographic <- vect(coords1, type = "polygon", crs = "EPSG:4326")
# 
# # Create same polygon in projected CRS (UTM Zone 30N)
# poly_projected <- project(poly_geographic, "EPSG:32630")
# 
# # Calculate metrics on both
# result_geo <- calculate_geometric_attributes(poly_geographic, metrics = "area")
# result_proj <- calculate_geometric_attributes(poly_projected, metrics = "area")
# 
# # Both should give similar results (using geodesic calculations by default)
# print(paste("Geographic CRS area:", round(result_geo$area, 0), "m²"))
# print(paste("Projected CRS area:", round(result_proj$area, 0), "m²"))
# 
# # Difference should be minimal due to default geodesic calculations
# print(paste(
#   "Difference:",
#   round(abs(result_geo$area - result_proj$area), 0),
#   "m²"
# ))

