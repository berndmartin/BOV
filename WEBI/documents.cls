 
 /*------------------------------------------------------------------------
    File        : documents
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Bernd Martin Dot Net
    Created     : Thu Aug 28 15:27:03 CEST 2014
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING helper.*.



CLASS WEBI.documents INHERITS helper.saxReader : 
  
  DEFINE PRIVATE TEMP-TABLE ttdocuments NO-UNDO 
    FIELD Id          AS CHARACTER
    FIELD cuid        AS CHARACTER 
    FIELD name        AS CHARACTER 
    FIELD folderId    AS CHARACTER 
    FIELD state       AS CHARACTER 
    INDEX IXID        IS PRIMARY UNIQUE 
                      ID ASC 
  /**/.

  DEFINE PUBLIC  VARIABLE hdocuments       AS HANDLE    NO-UNDO.
  DEFINE PRIVATE VARIABLE hqdocuments      AS HANDLE    NO-UNDO.
  
  DESTRUCTOR documents():
    EMPTY TEMP-TABLE ttdocuments.
  END DESTRUCTOR.
  
  METHOD PUBLIC VOID readDocuments(lcdata AS LONGCHAR):
    SUPER:readSax(lcdata).

    IF CAN-FIND(FIRST ttdocuments NO-LOCK)
    THEN DO:
      hdocuments = TEMP-TABLE ttdocuments:DEFAULT-BUFFER-HANDLE.
      CREATE QUERY hqdocuments.
      hqdocuments:SET-BUFFERS(hdocuments).
      hqdocuments:QUERY-PREPARE("FOR EACH ttdocuments").
      hqdocuments:QUERY-OPEN.
    END.
    ELSE DO:
      hdocuments  = ?.
      IF VALID-HANDLE(hqdocuments)
      THEN DELETE OBJECT hqdocuments.
    END.    
    
  END METHOD.
  
  METHOD PUBLIC HANDLE getTTQueryHdl
    (cTTName AS CHARACTER):
    
    CASE cTTName:
      WHEN "document" THEN RETURN hqdocuments.
      OTHERWISE.
    END CASE .    
    
    RETURN ?.  
  END METHOD.
  
  METHOD PUBLIC HANDLE getTTtableHdl
    (cTTName AS CHARACTER):
    
    CASE cTTName:
      WHEN "document" THEN RETURN hdocuments.
      OTHERWISE.
    END CASE .    
      
    RETURN ?.  
  END METHOD.

  METHOD PUBLIC HANDLE getFirstTT
    (cTTName AS CHARACTER):
    RETURN SUPER:getFirst(getTTtableHdl(cTTName),getTTQueryHdl(cTTName)).
  END METHOD. 
  
  METHOD PUBLIC HANDLE getNextTT
    (cTTName AS CHARACTER):
    RETURN SUPER:getNext(getTTtableHdl(cTTName),getTTQueryHdl(cTTName)).
  END METHOD. 

  METHOD PUBLIC HANDLE getLastTT 
    (cTTName AS CHARACTER):
    RETURN SUPER:getLast(getTTtableHdl(cTTName),getTTQueryHdl(cTTName)).
  END METHOD.
  
  METHOD PUBLIC HANDLE getCurrentTT
    (cTTName AS CHARACTER):
    RETURN SUPER:getCurrent(getTTtableHdl(cTTName)).
  END METHOD. 

  METHOD PUBLIC OVERRIDE VOID StartElement
    (pcNamespaceURI AS CHARACTER,
     pcLocalName    AS CHARACTER,
     pcElementName  AS CHARACTER,
     phAttributes   AS HANDLE):
 
    SUPER:StartElement(pcNameSpaceURI,pcLocalName,pcElementName,phAttributes). 
    
    CASE pcElementName:
      WHEN "documents" 
      THEN DO:
        emptytt().
        nReaderCnt = 0.
      END.
      WHEN "document" 
      THEN DO:
        emptytt().
        nReaderCnt = nReaderCnt + 1.
      END.
      OTHERWISE.
    END CASE.
    
  END METHOD.

  
  METHOD PUBLIC OVERRIDE VOID EndElement   
    (pcNamespaceURI AS CHARACTER,
     pcLocalName    AS CHARACTER,
     pcElementName  AS CHARACTER):
    
    SUPER:EndElement(pcNameSpaceURI,pcLocalName,pcElementName).
    
    CASE pcElementName:
      WHEN "document" 
        THEN DO:
          FIND FIRST ttdocuments EXCLUSIVE-LOCK  
               WHERE ttdocuments.ID   = getReader("ID")
          NO-ERROR.
          IF NOT AVAIL ttdocuments
          THEN CREATE ttdocuments.
          ASSIGN ttdocuments.ID       = getReader("ID")
                 ttdocuments.cuid     = getReader("Cuid")
                 ttdocuments.name     = getReader("name")
                 ttdocuments.folderid = getReader("folderId")
                 ttdocuments.state    = getReader("state")
          /**/.
        END.
      WHEN "documents" 
      THEN DO:
        DEFINE VARIABLE nCnt AS INTEGER  NO-UNDO.
        FOR EACH ttdocuments NO-LOCK:
          nCnt = nCnt + 1.
        END.
        IF nReaderCnt <> nCnt
        THEN MESSAGE "Not correct count of files"
             VIEW-AS ALERT-BOX.
      END.
      OTHERWISE.
    END CASE.
  END METHOD.
  
  METHOD PUBLIC CHARACTER getLogonToken (lcdata AS LONGCHAR):
   
    DEFINE VARIABLE cReturn  AS CHARACTER NO-UNDO. 
    DEFINE VARIABLE hDoc     AS HANDLE NO-UNDO.
    DEFINE VARIABLE hRoot    AS HANDLE NO-UNDO.
    DEFINE VARIABLE hChild   AS HANDLE NO-UNDO.
    DEFINE VARIABLE hChild1  AS HANDLE NO-UNDO.
    DEFINE VARIABLE hChild2  AS HANDLE NO-UNDO.
    DEFINE VARIABLE hText    AS HANDLE NO-UNDO.
    DEFINE VARIABLE i        AS INT NO-UNDO.
    DEFINE VARIABLE j        AS INT NO-UNDO.
    DEFINE VARIABLE h        AS int NO-UNDO.
    DEFINE VARIABLE cID      AS CHAR NO-UNDO.
    DEFINE VARIABLE cValue   AS CHAR NO-UNDO.
     
  	/* Create document and node references */
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF hRoot.
    CREATE X-NODEREF hChild.
    CREATE X-NODEREF hChild1.
    CREATE X-NODEREF hChild2.
    CREATE X-NODEREF hText.
     
    hDoc:LOAD("LONGCHAR",lcData,FALSE).
     
    hDoc:GET-DOCUMENT-ELEMENT(hRoot).
     
    Root: 
    DO i = 1 TO hRoot:NUM-CHILDREN:
     
      hRoot:GET-CHILD(hChild,i).
      
      IF hChild:NUM-CHILDREN < 1 
      THEN NEXT.
     
         
      hChild:GET-CHILD(hChild1,1).
     
      DO j = 1 TO INT(hChild1:NUM-CHILDREN):
        
        IF hChild1:NUM-CHILDREN < 1 
        THEN NEXT.
        
        hChild1:GET-CHILD(hChild2, j).
        
        DO h = 1 TO INT(hChild2:NUM-CHILDREN):
        
          IF hchild2:NUM-CHILDREN < 1
          THEN NEXT.
          
          hChild2:GET-CHILD(hText,h).
          
          cReturn = hText:NODE-VALUE.
          LEAVE Root.
                    
        END.
          
      END.
    END.
    
    DELETE OBJECT hDoc.
    DELETE OBJECT hRoot.
    DELETE OBJECT hChild.
    DELETE OBJECT hChild1.
    DELETE OBJECT hChild2.
    DELETE OBJECT hText.
    
    cReturn = TRIM(cReturn,CHR(10)).
    cReturn = TRIM(cReturn,CHR(13)).
    
    RETURN cReturn.
  
  END METHOD.

END CLASS.
