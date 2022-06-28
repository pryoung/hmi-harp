
FUNCTION hmi_get_harp_data, harpnum, status=status, overwrite=overwrite, quiet=quiet

;+
; NAME:
;     HMI_GET_HARP_DATA
;
; PURPOSE:
;     Downloads all of the HARP keyword data for the specified HARP
;     number. 
;
; CATEGORY:
;     SDO; HMI; HARP.
;
; CALLING SEQUENCE:
;     Result = HMI_GET_HARP_DATA( HarpNum )
;
; INPUTS:
;     HarpNum:  The HARP number.
;
; KEYWORD PARAMETERS:
;     OVERWRITE: If file already exists, then overwrite.
;     QUIET:  If set, then do not print information messages.
;
; OUTPUTS:
;     If successful, a file with a name of the form
;     'hmi_harp_NNNNN.txt' is created in the $HMI_HARP directory,
;     where NNNNN is the HARP number. The name of the file is returned
;     as an output. If a problem is found then an empty string is
;     returned. To read the file, use the routine HMI_READ_HARP_DATA. 
;
; OPTIONAL OUTPUTS:
;     Status:  An integer specifying the status of the query.
;                0 - OK.
;                1 - The user already has the HARP data.
;                2 - There are no data for this HARP number.
;                3 - The directory for storing the data does not
;                    exist. 
;
; EXAMPLE:
;     IDL> file=hmi_get_harp_data(7237)
;
; MODIFICATION HISTORY:
;     Ver.1, 01-Jul-2021, Peter Young
;     Ver.2, 25-Jul-2021, Peter Young
;       added /OVERWRITE keyword; added MTOT and AREA_ACR to output.
;     Ver.3, 27-Jun-2022, Peter Young
;       added /QUIET keyword.
;-


IF n_params() LT 1 THEN BEGIN
   print,'Use:  IDL> file = hmi_get_harp_data( harpnum [, status= ] )'
   return,''
ENDIF 

harpdir=getenv('HMI_HARP')
IF harpdir EQ '' THEN BEGIN
   print,'% HMI_GET_HARP_DATA: Please set the environment variable $HMI_HARP to point to the location where you'
   print,'                     want to store the HARP data.'
   return,''
ENDIF

chck=file_info(harpdir)
IF chck.exists EQ 0 THEN BEGIN
   outfile=''
   print,'% HMI_GET_HARP_DATA: the HARP directory was not found. Perhaps data disk is not connected?'
   status=3
   return,''
ENDIF 


url='http://jsoc.stanford.edu/cgi-bin/ajax/show_info?ds=hmi.sharp_720s['+trim(harpnum)+']&key=T_OBS,USFLUX,MEANGAM,NPIX,AREA,LAT_FWT,LON_FWT,NOAA_AR,MTOT,AREA_ACR,NACR'

status=0

sock_list,url,page
IF n_elements(page) LT 3 THEN BEGIN
   IF NOT keyword_set(quiet) THEN message,/cont,/info,'no data for this HARPNUM. Returning...'
   status=2
   return,-1
ENDIF 


hstr=strpad(trim(harpnum),5,fill='0')
outfile='hmi_harp_'+hstr+'.txt'
outfile=concat_dir(harpdir,outfile)
chck=file_info(outfile)
IF chck.exists EQ 1 AND NOT keyword_set(overwrite) THEN BEGIN
   IF NOT keyword_set(quiet) THEN message,/cont,/info,'file already exists. Set /overwrite to overwrite it. Returning...'
   status=1
ENDIF ELSE BEGIN 
   openw,lout,outfile,/get_lun
   FOR i=0,n_elements(page)-1 DO printf,lout,page[i]
   free_lun,lout
  ;
   IF NOT keyword_set(quiet) THEN message,/cont,/info,'created file '+outfile
ENDELSE
junk=temporary(page)

return,outfile

END
