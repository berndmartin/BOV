/* Bernd Martin Dot Net */
USING http.*.
USING WEBI.*.

DEFINE VARIABLE objConnection AS CLASS connection NO-UNDO.
DEFINE VARIABLE lcc           AS LONGCHAR         NO-UNDO.

objConnection = NEW connection("WebiUser","openWebi","secEnterprise","bmline01","6405").
IF VALID-OBJECT(objConnection)
THEN DO:
  
  lcc = objConnection:getResult("GET-DOCUMENTS").
  MESSAGE "GET-DOCUMENTS" SKIP STRING(lcc)
  VIEW-AS ALERT-BOX.
  
  DO WHILE VALID-HANDLE (objConnection:objWebiDocuments:getNextTT("Document")):
   
    MESSAGE VALID-HANDLE(objConnection:objWebiDocuments:getCurrentTT("Document"))
     SKIP objConnection:objWebiDocuments:getCurrentTT("Document")::id
     VIEW-AS ALERT-BOX.
  END.
  
  
  objConnection:objWebiDocuments:getFirstTT("Document").
  
  lcc = objConnection:getResult("GET-DOCUMENT").
  MESSAGE "GET-DOCUMENT" SKIP STRING(lcc)
  VIEW-AS ALERT-BOX.


  lcc = objConnection:getResult("GET-DOCUMENT-PROPERTIES").
  MESSAGE "GET-DOCUMENT-PROPERTIES" SKIP STRING(lcc)
  VIEW-AS ALERT-BOX.


  lcc = objConnection:getResult("GET-DOCUMENT-XML").
  MESSAGE "GET-DOCUMENT-XML" SKIP STRING(lcc)
  VIEW-AS ALERT-BOX.

  lcc = objConnection:getResult("GET-UNIVERSES").
  MESSAGE "GET-UNIVERSES" SKIP STRING(lcc)
  VIEW-AS ALERT-BOX.

  lcc = objConnection:getResult("GET-DOCUMENT-REPORTS").
  MESSAGE "GET-DOCUMENT-REPORTS" SKIP STRING(lcc)
  VIEW-AS ALERT-BOX.

  lcc = objConnection:getResult("GET-DOCUMENT-REPORT-DETAILS").
  MESSAGE "GET-DOCUMENT-REPORT-DETAILS" SKIP STRING(lcc)
  VIEW-AS ALERT-BOX.

  lcc = objConnection:getResult("GET-DOCUMENT-DATAPROVIDER").
  MESSAGE "GET-DOCUMENT-DATAPROVIDER" SKIP STRING(lcc)
  VIEW-AS ALERT-BOX.

  lcc = objConnection:getResult("GET-DOCUMENT-REPORT-SPECIFICATION").
  MESSAGE "GET-DOCUMENT-REPORT-SPECIFICATION" SKIP STRING(lcc)
  VIEW-AS ALERT-BOX.

  /* ........... */

  DELETE OBJECT objConnection.
END.

