 /*------------------------------------------------------------------------
    File        : socket
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Bernd Martin Dot Net
    Created     : Sun Aug 24 10:40:02 CEST 2014
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
&SCOPED-DEFINE TIMEOUT 500
ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS http.socket   : 
  
  DEFINE PRIVATE VARIABLE hSocket AS HANDLE NO-UNDO.
  
  CONSTRUCTOR socket():
    CREATE SOCKET hSocket.
  END CONSTRUCTOR.

  DESTRUCTOR socket():
    IF VALID-HANDLE(hSocket) 
    THEN DO:
      IF hSocket:CONNECTED() 
      THEN hSocket:DISCONNECT().
      DELETE OBJECT hSocket NO-ERROR.
    END.
  END DESTRUCTOR.

  METHOD PUBLIC LOGICAL connect
      (INPUT pcHost   AS CHARACTER):
    RETURN hSocket:CONNECT(pcHost). 
  END METHOD.
  
  METHOD PUBLIC LOGICAL connect
      (INPUT cHost   AS CHARACTER,
       INPUT iPort   AS INTEGER):
    RETURN connect(cHost,iPort,FALSE).
  END METHOD.
  
  METHOD PUBLIC LOGICAL connect
      (INPUT cHost   AS CHARACTER,
       INPUT iPort   AS INTEGER,
       INPUT lssl    AS LOGICAL):
    RETURN connect(SUBSTITUTE("-H &1 -S &2 &3",cHost,iPort,(IF lssl THEN '-ssl' ELSE ''))).
  END METHOD.
 
  METHOD PUBLIC LOGICAL connected():
    RETURN hSocket:CONNECTED().
  END METHOD.
    
  METHOD PUBLIC LOGICAL write (INPUT pcData AS CHARACTER):
    DEFINE VARIABLE lcData AS LONGCHAR   NO-UNDO.
    lcData = pcData.
    RETURN THIS-OBJECT:write( INPUT lcData ). 
  END METHOD.

  METHOD PUBLIC LOGICAL write (INPUT plcData AS LONGCHAR):
    DEFINE VARIABLE mpData  AS MEMPTR  NO-UNDO.
    DEFINE VARIABLE lreturn AS LOGICAL NO-UNDO.

    SET-SIZE(mpData) = 0.
    COPY-LOB FROM plcData TO OBJECT mpData.

    lreturn = THIS-OBJECT:write(mpData).
    SET-SIZE(mpData) = 0.

    RETURN lreturn.
  END METHOD.

  METHOD PUBLIC LOGICAL write (INPUT pmData AS MEMPTR):
    DEFINE VARIABLE lreturn     AS LOGICAL NO-UNDO.
        
    IF VALID-HANDLE(hSocket) 
    AND hSocket:CONNECTED() 
    THEN.
    ELSE RETURN FALSE.
    
    hSocket:WRITE(pmData, 1, GET-SIZE(pmData)).

    IF  hSocket:BYTES-WRITTEN > 0 
    AND hSocket:BYTES-WRITTEN = GET-SIZE(pmData) 
    THEN lReturn = TRUE.
    ELSE lReturn = FALSE.
    
    SET-SIZE(pmData) = 0.
    
    RETURN lreturn.
    
  END METHOD.

  METHOD PUBLIC VOID setSensitive():
    IF VALID-HANDLE(hSocket)
    AND hSocket:CONNECTED()
    THEN hSocket:SENSITIVE = TRUE.
  END METHOD.
  
  METHOD PUBLIC MEMPTR READ():
    DEFINE VARIABLE mpTemp   AS MEMPTR   NO-UNDO.
    DEFINE VARIABLE mpData   AS MEMPTR   NO-UNDO.
    DEFINE VARIABLE nCurSize AS INTEGER  NO-UNDO.

    SET-SIZE(mpData) = 0.

    IF NOT VALID-HANDLE(hSocket) 
    THEN RETURN mpData.
    
    DO WHILE hSocket:CONNECTED():
      
      IF  hSocket:CONNECTED()
      AND hSocket:GET-BYTES-AVAILABLE() > 0 
      THEN DO:
        SET-SIZE(mpTemp)       = 0.
        SET-BYTE-ORDER(mpTemp) = BIG-ENDIAN.
        SET-SIZE(mpTemp)       = hSocket:GET-BYTES-AVAILABLE().
    
        hSocket:READ(mpTemp,1,hSocket:GET-BYTES-AVAILABLE(),READ-EXACT-NUM).
        
        nCurSize = GET-SIZE(mpData).
        SET-SIZE(mpData) = nCurSize + GET-SIZE(mpTemp).
        COPY-LOB FROM mpTemp TO OBJECT mpData OVERLAY AT nCurSize + 1  NO-ERROR.
      END.
      ELSE DO:
        ETIME(YES).
        DO WHILE (hSocket:CONNECTED()               AND 
                  hSocket:GET-BYTES-AVAILABLE() = 0 AND 
                  ETIME < {&TIMEOUT}
                  /**/):
          /* wait */          
        END.
      END.
    END.
  
    /*
    MESSAGE GET-STRING(mpData,1)
    VIEW-AS ALERT-BOX.
    */
    
    SET-SIZE(mpTemp) = 0.
    RETURN mpData.
  
  END METHOD.
  
END CLASS.
