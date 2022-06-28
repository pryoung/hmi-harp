
FUNCTION hmi_read_harp_data, harpnum, file=file


;+
; NAME:
;     HMI_READ_HARP_DATA
;
; PURPOSE:
;     Reads the HARP keyword data for the specified HARP number. 
;
; CATEGORY:
;     SDO; HMI; HARP.
;
; CALLING SEQUENCE:
;     Result = HMI_READ_HARP_DATA( HarpNum )
;
; INPUTS:
;     HarpNum:  The HARP number (integer).
;
; OPTIONAL INPUTS:
;     File:   Directly specify the HARP data file to be read.
;	
; OUTPUTS:
;     A structure with the following tags:
;      .t_obs  String giving observation time.
;      .tt_jd  Julian date time.
;      .usflux  Total unsigned magnetic flux (Maxwells).
;      .area   De-projected area of region (micro-hemispheres).
;      .lat    Latitude of region center (degrees).
;      .lon    Longitude of region center (degrees).
;      .noaa_ar  NOAA AR number.
;      .radial_flux  Radial component of magnetic flux (Maxwells).
;
; RESTRICTIONS:
;     The routine expects a template file with the name
;     'hmi_harp_template.save' to be located in $HMI_HARP. This file
;     is needed to read the HARP text files.
;
; EXAMPLE:
;     IDL> data=hmi_read_harp_data(7237)
;     IDL> file=concat_dir(getenv('HMI_HARP'),'hmi_harp_07237.txt')
;     IDL> data=hmi_read_harp_data(file=file)
;
; MODIFICATION HISTORY:
;     Ver.1, 01-Jul-2021, Peter Young
;     Ver.2, 25-Jul-2021, Peter Young
;       added mtot, area_acr and nacr tags to output structure.
;-


harpdir=getenv('HMI_HARP')
IF n_elements(file) NE 0 THEN BEGIN
   harpfile=file
ENDIF ELSE BEGIN
   chck=file_info(harpdir)
  ;
   harpfile='hmi_harp_'+strpad(trim(harpnum),5,fill='0')+'.txt'
   harpfile=concat_dir(harpdir,harpfile)
ENDELSE 
;
chck=file_info(harpfile)
IF chck.exists EQ 0 THEN BEGIN
   print,'% HMI_READ_HARP_DATA: file not found. Returning...'
   return,-1
ENDIF

tempfile=concat_dir(harpdir,'hmi_harp_template.save')
chck=file_info(tempfile)
IF chck.exists EQ 0 THEN BEGIN
   print,'% HMI_READ_HARP_DATA: the ascii template file was not found. Returning...'
   return,-1
ENDIF 
restore,tempfile
;
data=read_ascii(harpfile,template=template)
;
t_obs=anytim2utc(/ccsds,data.field01)
tt_jd=tim2jd(t_obs)

meangam=data.field03  ; mean angle of magnetic field vector
k=where(trim(meangam) NE 'nan')
meangam=float(meangam[k])

t_obs=t_obs[k]
tt_jd=tt_jd[k]
usflux=data.field02[k]  ; total unsigned flux, Maxwells
npix=data.field04[k]
area=data.field05[k]*3.044d16  ; cm^2
lat=data.field06[k]
lon=data.field07[k]
noaa_ar=data.field08[k]
radial_flux=usflux*sin(meangam/360.*2.*!pi)
  ;
output={ t_obs:t_obs[k], $
         tt_jd:tt_jd[k], $
         usflux:data.field02[k], $  ; total unsigned flux, Maxwells
         npix:data.field04[k], $
         area:data.field05[k]*3.044d16, $  ; cm^2
         lat:data.field06[k], $
         lon:data.field07[k], $
         noaa_ar:data.field08[k], $
         mtot: data.field09[k], $
         area_acr:data.field10[k]*3.044d16, $ ; cm^2
         nacr: data.field11[k], $
         radial_flux:usflux*sin(meangam/360.*2.*!pi) }

return,output

END
