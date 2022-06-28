
FUNCTION hmi_sharp_files, harpnum, type, cea=cea, count=count, quiet=quiet

;+
; NAME:
;     HMI_SHARP_FILES
;
; PURPOSE:
;     Finds HMI SHARP files on the user's computer.
;
; CATEGORY:
;     HMI; SHARP
;
; CALLING SEQUENCE:
;     Result = HMI_SHARP_FILES( HarpNum, Type )
;
; INPUTS:
;     HarpNum:  HMI HARP number.
;     Type:     String specifying the file type. Run the routine
;               without specifying TYPE to see example values.
;
; OPTIONAL INPUTS:
;	Parm2:	Describe optional inputs here. If you don't have any, just
;		delete this section.
;	
; KEYWORD PARAMETERS:
;     CEA:   If set, then look for the cylindrical-equal-area (CEA)
;            files.
;     QUIET: If set, then do not print information messages to the
;            screen. 
;
; OUTPUTS:
;     A string array containing filenames found. If none found, then
;     an empty string is returned.
;
; OPTIONAL OUTPUTS:
;     Count:   The number of files found.
;
; RESTRICTIONS:
;     The environment variables $HMI_SHARP and $HMI_SHARP_CEA should
;     be set to point to the locations of files. The SHARP files
;     should be organized in sub-directories with the HARP number. For
;     example, /0001, /0723 or /7260.
;
; EXAMPLE:
;     IDL> files=hmi_sharp_files(7260,'field')
;     IDL> files=hmi_sharp_files(7260,'Br',/cea)
;
; MODIFICATION HISTORY:
;     Ver.1, 27-Jul-2021, Peter Young
;-


IF n_elements(type) EQ 0 THEN BEGIN
   IF keyword_set(cea) THEN BEGIN
      print,'% HMI_SHARP_FILES: TYPE not specified. Please specify an image type using a string. Examples include:'
      print,'    Br - B-radial, positive up'
      print,'    Bp - B-phi, positive westwar'
      print,'    Bt - B-theta, positive southward'
      print,'    conf_disambig - confidence of disambiguation result'
      print,'    bitmap - mask for the patch in CEA coordinates'
      print,''
      print,' Note that TYPE is case-sensitive.'
   ENDIF ELSE BEGIN
      print,'% HMI_SHARP_FILES: TYPE not specified. Please specify an image type using a string. Examples include:'
      print,'    field - magnetic field strength'
      print,'    inclination - relative to line of sight (degrees)'
      print,'    azimuth - azimuth angle (degrees), zero is northward'
      print,'    magnetogram - LOS magnetogram'
      print,''
      print,' Note that TYPE is case-sensitive.'
   ENDELSE
   print,''
   print,'See http://jsoc.stanford.edu/doc/data/hmi/sharp/sharp.htm for full list of files.'
   count=0
   return,''
ENDIF

IF keyword_set(cea) THEN env=getenv('HMI_SHARP_CEA') ELSE env=getenv('HMI_SHARP')

dir=concat_dir(env,strpad(trim(harpnum),4,fill='0'))


files=file_search(dir,'*.'+type+'.fits',count=count)

IF NOT keyword_set(quiet) THEN print,'% HMI_SHARP_FILES: '+trim(count)+' files found.'

return,files


END
