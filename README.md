## Dockerized CDO

This Image provides the Climate Data Operators (CDO) command-line tool, within a Docker container. CDO is a collection of command-line operators for manipulating and analyzing climate and forecast data files.

### Quick Start

```bash
docker run --rm -v ${PWD}:/data ghcr.io/hstin-de/cdo --help
```

Get Information about a NetCDF or GRIB file:
```bash
docker run --rm -v ${PWD}:/data ghcr.io/hstin-de/cdo info example.grib2
```

Replace `example.grib2` with the name of your NetCDF or GRIB file.

### Building the Image

```bash
docker build -t hstin-de/cdo .
```

This command builds the Docker image and tags it as `hstin-de/cdo`. You can adjust the tag according to your versioning or naming conventions.

---


Refer to the [CDO User Guide](https://code.mpimet.mpg.de/projects/cdo/) for more comprehensive details on using CDO and its commands.