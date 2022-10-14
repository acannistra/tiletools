<p align="center">
    <h2>
        <code>tiletools</code>
    </h2>
    <p>
        <em>A collection of scripts for dealing with Web Mercator tiles on the commandline.</em>
    </p>
</p>

---

### `check_tiles_s3.sh`

**Usage:** `./check_tiles_s3.sh bucket prefix extension zoom west,south,east,north|path to GeoJSON`
**Dependencies**: AWS CLI, [supermercado](https://github.com/mapbox/supermercado).

Determine whether a XYZ tileset on AWS S3 contains all of the tiles
it should. This works by: 
   - Enumerating all of the tiles within bounding box or GeoJSON at specified zoom
   - Listing the contents of the S3 bucket or bucket/prefix.
   - Comparing the two tile lists to find missing tiles on S3

The missing tiles are printed to `stdout`, one `X,Y,Z` tile at a time.

The output can be piped to `mercantile` to get a GeoJSON of all
missing tile boundaries as such:

```bash
./check_tiles_s3.sh bucket prefix 10 path.geojson \
     | awk '{print "["$0"]"} ' \
     | mercantile shapes --collect > missing_tiles.geojson
```

:warning: This requires AWS credentials to be present in the environment. 

### `mvt_to_ogr.sh`

**Usage:** `./mvt_to_ogr.sh mvt outfile`
**Dependencies**: GDAL

Converts a Mapbox Vector Tile (as PBF) to a georeferenced OGR-compatible
format. GDAL inputs/outputs expected, which means you can use virtual 
files like `/vsis3/` and `/vsicurl/` for both inputs and outputs.

For example:

```bash
./mvt_to_ogr.sh /vsicurl/https://tileserver.earth/tiles/12/320/1170.pbf tile.geojson
```