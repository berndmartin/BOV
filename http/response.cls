 /*------------------------------------------------------------------------
    File        : response
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Bernd Martin Dot Net
    Created     : Sun Aug 24 11:01:04 CEST 2014
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING helper.base.

&SCOPED-DEFINE PATH "c:/temp/" 

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS http.response:
 
  METHOD PRIVATE LOGICAL ValidateReturn (
    INPUT  cResult AS CHARACTER,
    OUTPUT nLength AS INTEGER ):

    DEFINE VARIABLE cLength AS CHARACTER NO-UNDO.
    DEFINE VARIABLE nResult AS INTEGER   NO-UNDO.      

    ASSIGN 
      cResult = LEFT-TRIM(cResult,CHR(10))
      cResult = LEFT-TRIM(cResult,CHR(13))
    /**/.
    
    IF INDEX(cResult,"Content-Length") > 0
    THEN cLength = SUBSTRING(cResult,
                             INDEX(cResult,"Content-Length") + 14,
                             INDEX(cResult,CHR(13),INDEX(cResult,"Content-Length")) - INDEX(cResult,"Content-Length") - 14
                             ) NO-ERROR.
    ELSE nLength = -1.                         

    IF INDEX(cResult,CHR(10)) > 0
    THEN cResult = SUBSTRING(cResult,1,INDEX(cResult,CHR(10))).
    
    IF INDEX(cResult,"HTTP") > 0 
    THEN cResult = SUBSTRING(cResult,INDEX(cResult,"HTTP") + 9 , 3 ) NO-ERROR.
    
    IF  cResult > ""
    AND base:isNumerical(cResult)
    THEN nResult = INTEGER(cResult).
      /**/.
    
    cLength = TRIM(REPLACE(cLength,":","")," ").
   
    IF  cLength > ""
    AND helper.base:isNumerical(cLength)
    THEN nLength = INTEGER(cLength).
    
    RETURN (nResult = 200).
  
  END METHOD.
  
  METHOD PUBLIC LONGCHAR RemoveHeader (
    mpData    AS MEMPTR,
    cXMLEntry AS CHARACTER ):
    
    DEFINE VARIABLE lcFile      AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE lcXmlResult AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE nContLength AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cFileStart  AS CHARACTER NO-UNDO.
    
    IF GET-SIZE(mpData) = 0 
    THEN RETURN "".
    
    /* save result to file */
    COPY-LOB FROM OBJECT mpData TO FILE   base:getUniqueFileName({&PATH},"txt").
    COPY-LOB FROM OBJECT mpData TO OBJECT lcFile.
  
    cFileStart = SUBSTRING(lcFile,1,MIN(1000,LENGTH(lcFile))).  
    IF ValidateReturn(cFileStart,OUTPUT nContLength )
    OR cFileStart BEGINS cXMLEntry
    THEN DO:
      lcXMLResult = SUBSTRING(lcFile,INDEX(lcFile,cXMLEntry)) NO-ERROR.
      
      IF  nContLength >= 0
      AND LENGTH(lcxmlresult) <> nContLength
      THEN MESSAGE "content length not correct" SKIP
           ERROR-STATUS:GET-MESSAGE(1)
           VIEW-AS ALERT-BOX.
           
    END.
    ELSE DO:
    
      MESSAGE "error in result#" SKIP 
        STRING(lcFile)
        VIEW-AS ALERT-BOX ERROR.
    
    END.
    
    SET-SIZE(mpData) = 0.
    
    RETURN lcXmlResult.
    
  END METHOD.
  
  
END CLASS.
