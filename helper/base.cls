 /*------------------------------------------------------------------------
    File        : base
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Bernd Martin Dot Net
    Created     : Wed Aug 25 13:38:50 CEST 2014
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.


CLASS helper.base   : 
  
  METHOD PUBLIC STATIC VOID OUT
    (cOutput AS CHARACTER):
    MESSAGE coutput
    VIEW-AS ALERT-BOX. 
  END METHOD.  
  
  METHOD PUBLIC STATIC CHARACTER getUniqueFileName
    (cPreFix  AS CHARACTER,
     cPostFix AS CHARACTER,
     cType    AS CHARACTER ):
    
    RETURN (IF cPrefix > ""  THEN cPrefix ELSE "")
           + SUBSTITUTE("&1&2&3-&4-",STRING(YEAR(TODAY),"9999"), STRING(MONTH(TODAY),"99"),STRING(DAY(TODAY),"99"), REPLACE(STRING(TIME,"HH:MM:SS"),":",""))
           + GUID(GENERATE-UUID)
           + (IF cPostFix > "" THEN cPostFix ELSE "")
           + (IF cType > "" THEN "." + TRIM(cType,".") ELSE "")
           /**/.
  
  END METHOD.

  METHOD PUBLIC STATIC CHARACTER getUniqueFileName
    (cPreFix AS CHARACTER,
     cType AS CHARACTER   ):
    RETURN getUniqueFileName(cPreFix,"",cType).
  END METHOD.

  METHOD PUBLIC STATIC CHARACTER getUniqueFileName
    (cType AS CHARACTER ):
    RETURN getUniqueFileName("","",cType).
  END METHOD.
  
  METHOD PUBLIC STATIC CHARACTER getUniqueFileName():
    RETURN getUniqueFileName("","","").
  END METHOD.

  METHOD PUBLIC STATIC LOGICAL isNumerical (cNumber AS CHARACTER):
    DEFINE VARIABLE lreturn AS LOGICAL NO-UNDO.
    
    IF INDEX(cNumber,",") > 0 
    OR INDEX(cNumber,".") > 0 
    THEN DECIMAL(cNumber) NO-ERROR.
    ELSE INTEGER(cNumber) NO-ERROR.
    
    IF ERROR-STATUS:ERROR
    THEN lreturn = FALSE.
    ELSE lreturn = TRUE.

    RETURN lreturn.   /* Function return value. */
    
  END METHOD.

END CLASS.
