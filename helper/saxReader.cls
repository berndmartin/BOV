 /*------------------------------------------------------------------------
    File        : saxReader
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Bernd Martin Dot Net
    Created     : Fri Aug 29 10:01:07 CEST 2014
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.


CLASS helper.saxReader   : 

  DEFINE PROTECTED VARIABLE cCurrentElement AS CHARACTER NO-UNDO.
  DEFINE PROTECTED VARIABLE nReaderCnt      AS INTEGER   NO-UNDO.
  
  DEFINE PROTECTED TEMP-TABLE ttReader NO-UNDO 
    FIELD element     AS CHARACTER 
    FIELD cValue      AS CHARACTER
    INDEX IXE         IS PRIMARY UNIQUE
                      element
  /**/.

  METHOD PUBLIC VOID readSax(
    lcdata AS LONGCHAR):
      
    DEFINE VARIABLE hSaxReader AS HANDLE NO-UNDO.
    DEFINE VARIABLE hCallbacks AS HANDLE NO-UNDO.

    CREATE SAX-READER hSaxReader.
    RUN helper/sax-reader.p PERSISTENT SET hCallbacks (THIS-OBJECT) .
    hSaxReader:HANDLER = hCallbacks.
    hSaxReader:SET-INPUT-SOURCE("LONGCHAR", lcdata).
    hSaxReader:SAX-PARSE-FIRST() NO-ERROR.
    REPEAT WHILE hSaxReader:PARSE-STATUS = SAX-RUNNING:
      hSaxReader:SAX-PARSE-NEXT() NO-ERROR.
    END.
    
    DELETE OBJECT    hSaxReader.
    DELETE PROCEDURE hCallbacks.
  
  END METHOD.

  METHOD PUBLIC VOID Characters 
    (ppText     AS MEMPTR,
     piNumChars AS INTEGER):

    FIND FIRST ttreader 
         WHERE ttreader.Element = cCurrentElement
    EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAIL ttreader 
    THEN CREATE ttreader.
    
    ASSIGN ttreader.Element = cCurrentElement
           ttreader.cValue  = ttreader.cValue + GET-STRING(ppText,1,piNumChars).
    /**/.
    
    SET-SIZE(ppText) = 0.
  END METHOD .

  METHOD PUBLIC VOID StartElement
    (pcNamespaceURI AS CHARACTER,
     pcLocalName    AS CHARACTER,
     pcElementName  AS CHARACTER,
     phAttributes   AS HANDLE):
 
    cCurrentElement = pcElementName.
    
  END METHOD.

  METHOD PUBLIC VOID emptyTT():
    EMPTY TEMP-TABLE ttreader.
  END METHOD.

  METHOD PUBLIC VOID EndElement 
    (pcNamespaceURI AS CHARACTER,
     pcLocalName    AS CHARACTER,
     pcElementName  AS CHARACTER):
    
  END METHOD.

  METHOD PROTECTED CHARACTER getReader 
    (cElement AS CHARACTER):
    
    FIND FIRST ttreader NO-LOCK 
         WHERE ttreader.element = cElement
    NO-ERROR.
    IF AVAILABLE ttreader
    THEN RETURN ttreader.cValue.      
    ELSE RETURN "". 
    
  END METHOD.

  METHOD PUBLIC HANDLE getFirst
    (hTTtable AS HANDLE, 
     hTTquery AS HANDLE ):
  
    IF  VALID-HANDLE(hTTQuery)
    AND VALID-HANDLE(hTTtable)
    AND hTTQuery:GET-FIRST(NO-LOCK)
    AND hTTtable:AVAILABLE  
    THEN RETURN hTTtable.
    
    RETURN ?.
  END METHOD. 

  METHOD PUBLIC HANDLE getNext
    (hTTtable AS HANDLE, 
     hTTquery AS HANDLE ):
  
    IF  VALID-HANDLE(hTTQuery)
    AND VALID-HANDLE(hTTtable)
    AND NOT hTTQuery:QUERY-OFF-END
    AND hTTQuery:GET-NEXT(NO-LOCK)
    AND hTTtable:AVAILABLE  
    THEN RETURN htttable.
    
    RETURN ?.
  END METHOD. 

  METHOD PUBLIC HANDLE getCurrent
    (hTTtable AS HANDLE):
    
    IF  VALID-HANDLE(hTTtable)
    AND hTTtable:AVAILABLE 
    THEN RETURN hTTtable.
    
    RETURN ?.
  END METHOD. 

  METHOD PUBLIC HANDLE getLast
    (hTTtable AS HANDLE, 
     hTTquery AS HANDLE ):
    
    IF  VALID-HANDLE (hTTquery)
    AND VALID-HANDLE (hTTtable)
    AND hTTquery:GET-LAST(NO-LOCK)
    AND hTTtable:AVAILABLE 
    THEN RETURN hTTtable.
    
    RETURN ?.
  END METHOD. 

END CLASS.
