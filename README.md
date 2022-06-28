# IDL software for working with HMI HARP and SHARP datasets

## Information sources

https://pyoung.org/quick_guides/hmi_harp_data.html

## Getting started

Create the  environment variables $HMI_HARP, $HMI_SHARP and $HMI_SHARP_CEA for storing HARP, SHARP and SHARP-CEA datasets. For example, I have the following lines in my idl_startup.pro file:

```
setenv,'HMI_HARP=/Volumes/PRY_DATA_3/sdo/hmi/harp'
setenv,'HMI_SHARP=/Volumes/PRY_DATA_3/sdo/hmi/sharp'
setenv,'HMI_SHARP_CEA=/Volumes/PRY_DATA_3/sdo/hmi/sharp_cea'
```

## HARP numbers and NOAA active region numbers

HMI assign their own index to active regions, referring to them as HMI Active Region Patches (HARPs). When you download HARP (or SHARP) data you will generally use the HARP number. When you use the IDL HARP routines below you will see that one of the tags in the output structure is NOAA_AR, i.e., the NOAA active region number. Note that not all HARPs have a NOAA AR number, and some HARPs may include multiple NOAA AR numbers.

## HARP data

The HARP data consists of scalar parameters tabulated as a function of time over the lifetime of the active region. The IDL routine `hmi_get_harp_data` downloads these tables from the JSOC and puts them in the $HMI_HARP directory. A table can be read into an IDL structure with `hmi_read_harp_data`. For example:

```
IDL> file=hmi_get_harp_data(7237)
IDL> data=hmi_read_harp_data(file=file)
```

The tags of the data structure are:

```
IDL> help,data,/str
** Structure <1503f808>, 12 tags, length=106632, data length=106632, refs=1:
   T_OBS           STRING    Array[1481]
   TT_JD           DOUBLE    Array[1481]
   USFLUX          FLOAT     Array[1481]
   NPIX            LONG      Array[1481]
   AREA            DOUBLE    Array[1481]
   LAT             FLOAT     Array[1481]
   LON             FLOAT     Array[1481]
   NOAA_AR         LONG      Array[1481]
   MTOT            FLOAT     Array[1481]
   AREA_ACR        DOUBLE    Array[1481]
   NACR            LONG      Array[1481]
   RADIAL_FLUX     FLOAT     Array[1481]
```
