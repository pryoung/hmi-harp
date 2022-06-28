

FUNCTION hmi_check_usflux, harpnum, cea=cea


;+
; NAME:
;     HMI_CHECK_USFLUX
;
; PURPOSE:
;     This routine is a sanity check to make sure the method for computing
;     USFLUX from the SHARP maps is consistent with the HARP value.
;
; CATEGORY:
;     SDO; HMI; SHARP.
;
; CALLING SEQUENCE:
;     Result = HMI_CHECK_USFLUX( HarpNum )
;
; INPUTS:
;     HarpNum:  Integer specifying the HARP number.
;
; OPTIONAL INPUTS:
;	Parm2:	Describe optional inputs here. If you don't have any, just
;		delete this section.
;	
; KEYWORD PARAMETERS:
;     CEA:   If set, then the CEA SHARP files are checked.
;
; OUTPUTS:
;     A structure containing the results:
;      .t_obs  Time of SHARP file.
;      .usflux Total unsigned flux derived from SHARP file.
;      .usflux_kywd  Total unsigned flux from HARP keyword.
;      .cmask  CMASK keyword.
;
; EXAMPLE:
;     IDL> r=hmi_check_usflux(7260,/cea)
;
; MODIFICATION HISTORY:
;     Ver.1, 27-Jun-2022, Peter Young
;-



sh_files_br=hmi_sharp_files(harpnum,'Br',cea=cea,count=c_br)
sh_files_cd=hmi_sharp_files(harpnum,'conf_disambig',cea=cea,count=c_cd)
sh_files_bm=hmi_sharp_files(harpnum,'bitmap',cea=cea,count=c_bm)

IF c_br NE c_cd OR c_br NE c_bm THEN BEGIN
  message,/info,/cont,'The numbers of files of each type do not match. Try re-downloading from JSOC.'
  return,-1
ENDIF 

n=c_br

message,/cont,/info,'Processing '+trim(n)+' files...'

str={ usflux_kywd: 0., usflux: 0., cmask: 0l, cmask_kywd: 0l, t_obs: '' }
output=replicate(str,n)


read_sdo,sh_files_br,index,data,/silent,/use_shared_lib
read_sdo,sh_files_cd,cindex,cdata,/silent,/use_shared_lib
read_sdo,sh_files_bm,bindex,bdata,/silent,/use_shared_lib

output.usflux_kywd=index.usflux
output.cmask_kywd=index.cmask
output.t_obs=anytim2utc(/ccsds,index.t_obs,/trunc)

FOR i=0,n-1 DO BEGIN
  ;
  pix_size=index[i].cdelt1*index[i].cdelt2*(2.*!pi)^2*(6.96e10)^2/360.^2

  im=data[*,*,i]
  cim=cdata[*,*,i]
  bim=bdata[*,*,i]
  ;
  k=where(cim EQ 90 AND bim GE 33,nk)

  output[i].usflux=total(abs(im[k]))*pix_size
  output[i].cmask=nk
   
ENDFOR

return,output

END
