 /*------------------------------------------------------------------------
    File        : request
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Bernd Martin Dot Net
    Created     : Sun Aug 24 10:55:15 CEST 2014
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
ROUTINE-LEVEL ON ERROR UNDO, THROW.

&SCOPED-DEFINE STRINGSIZE 3000


CLASS http.request:
 
  DEFINE PRIVATE TEMP-TABLE ttrequest NO-UNDO
    FIELD cLine AS CHARACTER 
  /**/.

  DESTRUCTOR request():
    EMPTY TEMP-TABLE ttrequest.
  END DESTRUCTOR.
  
  METHOD PUBLIC VOID prepare (cValue AS CHARACTER):
    DEFINE VARIABLE lcValue AS LONGCHAR NO-UNDO.

    lcValue = cValue.
    THIS-OBJECT:prepare(lcValue).
  END METHOD.
    
  METHOD PUBLIC VOID prepare (mpValue AS MEMPTR):
    DEFINE VARIABLE lcValue AS LONGCHAR NO-UNDO.

    COPY-LOB FROM OBJECT mpValue TO OBJECT lcValue.
    SET-SIZE(mpValue) = 0.
    THIS-OBJECT:prepare(lcValue).
  END.
    
  METHOD PUBLIC VOID prepare (lcValue AS LONGCHAR):
    DEFINE VARIABLE cTemp AS CHARACTER NO-UNDO.
    
    DO WHILE LENGTH(lcValue) > 0 TRANSACTION:
      CREATE ttrequest.
      ASSIGN cTemp           = SUBSTRING(lcValue,1,MIN(LENGTH(lcValue),{&STRINGSIZE}))
             lcValue         = SUBSTRING(lcValue,LENGTH(ctemp) + 1,-1)
             ttrequest.cLine = cTemp
      /**/.
    END.
  END METHOD.
  
  METHOD PUBLIC LONGCHAR getRequest():
    DEFINE VARIABLE lcReturn AS LONGCHAR NO-UNDO.
    FOR EACH ttrequest NO-LOCK:
      lcReturn = lcReturn + ttRequest.cLine.
    END.
    RETURN lcReturn.
  END METHOD.

END CLASS.
