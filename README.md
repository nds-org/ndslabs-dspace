# DSpace 5.4

Resources to create the Dspace Docker image for use in [NDS Labs](https://github.com/nds-org/ndslabs).

This is a preliminary containerization of [DSpace](http://www.dspace.org/) for use with the NDS Labs system and assumes a PostgreSQL database. This image is referenced in the [NDS Labs Service Catalog](https://github.com/nds-org/ndslabs-specs).

A few notes:
* Default user interface is XMLUI
* File data is stored in /dspace
* ADMIN_EMAIL environment variable must be set
* Assumes Postgres database exists during startup

## Documentation
Documentation for Dataverse can be found here: https://wiki.duraspace.org/display/DSDOC5x/DSpace+5.x+Documentation

## See also
* https://github.com/nds-org/ndslabs
* https://github.com/nds-org/ndslabs-specs
