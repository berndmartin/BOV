 /*------------------------------------------------------------------------
    File        : connection
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Bernd Martin Dot Net
    Created     : Mon Aug 25 09:14:31 CEST 2014
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING WEBI.documents.
USING http.*.

&SCOPED-DEFINE CRLF chr(13) + chr(10)

CLASS WEBI.connection   :
  
  DEFINE PRIVATE PROPERTY cuserName          AS CHARACTER NO-UNDO GET. SET.
  DEFINE PRIVATE PROPERTY cpassWord          AS CHARACTER NO-UNDO GET. SET.
  DEFINE PRIVATE PROPERTY cauthType          AS CHARACTER NO-UNDO GET. SET.
  DEFINE PRIVATE PROPERTY pcServer          AS CHARACTER NO-UNDO GET. SET.
  DEFINE PRIVATE PROPERTY pnPort            AS INTEGER   NO-UNDO GET. SET.
  
  DEFINE PUBLIC  PROPERTY baseURL           AS CHARACTER NO-UNDO GET. PRIVATE SET.
  DEFINE PUBLIC  PROPERTY baseVersion       AS CHARACTER NO-UNDO GET. PRIVATE SET.
  DEFINE PUBLIC  PROPERTY logonURL          AS CHARACTER NO-UNDO GET. PRIVATE SET.
  DEFINE PUBLIC  PROPERTY logoffURL         AS CHARACTER NO-UNDO GET. PRIVATE SET.
  DEFINE PUBLIC  PROPERTY infoStoreQueryURL AS CHARACTER NO-UNDO GET. PRIVATE SET.
  DEFINE PUBLIC  PROPERTY baseWebiURL       AS CHARACTER NO-UNDO GET. PRIVATE SET.
  DEFINE PUBLIC  PROPERTY baseUniversesURL  AS CHARACTER NO-UNDO GET. PRIVATE SET.
  
  DEFINE PUBLIC  PROPERTY logonToken        AS CHARACTER NO-UNDO GET. PRIVATE SET.
  
  DEFINE PUBLIC  VARIABLE objWebiDocuments  AS CLASS documents NO-UNDO.
  
    
  CONSTRUCTOR connection 
    ( cName     AS CHARACTER,
      cPassword AS CHARACTER,
      cAuth     AS CHARACTER,
      cServer   AS CHARACTER,
      cPort     AS CHARACTER ):
  
    THIS-OBJECT(cName,cPassword,cAuth,cServer,int(cPort)).
  
  END CONSTRUCTOR.

  CONSTRUCTOR connection 
    ( cName      AS CHARACTER,
      icPassword AS CHARACTER,
      cAuth      AS CHARACTER,
      cServer    AS CHARACTER,
      nPort      AS INTEGER  ):
    
    ASSIGN 
      cuserName    = cName
      cpassWord    = icPassword
      cauthType    = cAuth
      pcServer     = cServer
      pnPort       = nPort    
      THIS-OBJECT:baseURL           = SUBSTITUTE("http://&1:&2/biprws",cServer,nPort)
      THIS-OBJECT:baseVersion       = "v1"
      THIS-OBJECT:logonURL          = THIS-OBJECT:baseURL + "/logon/long" 
      THIS-OBJECT:logoffURL         = THIS-OBJECT:baseURL + "/logoff"
      THIS-OBJECT:infoStoreQueryURL = THIS-OBJECT:baseURL + "/infostore"
      THIS-OBJECT:baseWebiURL       = THIS-OBJECT:baseURL + "/raylight/" + THIS-OBJECT:baseVersion + "/documents"
      THIS-OBJECT:baseUniversesURL  = THIS-OBJECT:baseURL + "/raylight/" + THIS-OBJECT:baseVersion + "/universes"
    /**/. 
    
    objWebiDocuments = NEW documents().
    
    THIS-OBJECT:getResult("LOGIN").
    
    IF NOT isValidToken()
    THEN DELETE OBJECT THIS-OBJECT.
    
  END CONSTRUCTOR.
  
  DESTRUCTOR connection():

    IF VALID-OBJECT(objWebiDocuments)
    THEN DELETE OBJECT objWebiDocuments. 

    IF isValidToken()
    THEN THIS-OBJECT:getResult("LOGOFF").
    
  END DESTRUCTOR.
    
  METHOD PRIVATE CHARACTER loginStringXML ():
    
    RETURN SUBSTITUTE('<attrs><attr name="userName" type="string" >&1</attr><attr name="password" type="string" >&2</attr><attr name="auth" type="string" possibilities="secEnterprise,secLDAP,secWinAD,secSAPR3">&3</attr></attrs>',
    						  cuserName,
    						  cpassWord,
    						  cauthType
            /**/).
  
  END METHOD.

  METHOD PRIVATE CHARACTER loginStringJSON ():
    
    RETURN CHR(123) 
         + SUBSTITUTE('"userName":"&1","password":"&2","auth":"&3"',
    				    cuserName,
    					cpassWord,
    					cauthType )
    	 + CHR(125).
  
  END METHOD.

  METHOD PUBLIC LOGICAL isValidToken():
  
    RETURN (THIS-OBJECT:LogonToken > "").
      
  END METHOD.

  METHOD PUBLIC LONGCHAR getResult (cType AS CHARACTER):
  
    DEFINE VARIABLE objHttpRequest    AS CLASS request   NO-UNDO.
    DEFINE VARIABLE lcReturn          AS LONGCHAR        NO-UNDO.

    IF cType <> "LOGIN"
    AND NOT isValidToken() 
    THEN RETURN "".
    
    objHttpRequest = NEW REQUEST().
    
    CASE cType:
      WHEN "LOGOFF"
      THEN DO:
        objHttpRequest:prepare(SUBSTITUTE('POST &1 HTTP/1.0',logoffURL) + {&CRLF}).
        objHttpRequest:prepare("Accept: application/xml" + {&CRLF}).
        objHttpRequest:prepare(SUBSTITUTE('X-SAP-LogonToken: "&1"',logonToken) + {&CRLF}). 
        objHttpRequest:prepare("Content-Length: 0" + {&CRLF} + {&CRLF}). 
        THIS-OBJECT:LogonToken = STRING(getResult(cType,objHttpRequest:getRequest(),"")).
        THIS-OBJECT:LogonToken = "".
      END.
      WHEN "LOGIN"         
      THEN DO:
        DEFINE VARIABLE cLogin AS CHARACTER NO-UNDO.
        cLogin = loginStringXML().
        objHttpRequest:prepare(SUBSTITUTE('POST &1 HTTP/1.0' + {&CRLF},logonURL)).
        objHttpRequest:prepare("Content-Type: application/xml" + {&CRLF}). 
        objHttpRequest:prepare("Accept: application/xml" + {&CRLF}).
        objHttpRequest:prepare(SUBSTITUTE("Content-Length: &1",LENGTH(cLogin)) + {&CRLF} + {&CRLF}).
        objHttpRequest:prepare(cLogin + {&CRLF}).
        THIS-OBJECT:LogonToken = objWebiDocuments:getLogonToken(getResult(cType,objHttpRequest:getRequest(),"<entry")).
      END.
      WHEN "GET-DOCUMENTS"  
      THEN DO:
        objHttpRequest:prepare(SUBSTITUTE('GET &1?limit=&2&&offset=&3 HTTP/1.0' + {&CRLF},baseWebiURL,3,0)).
        objHttpRequest:prepare("Accept: application/xml" + {&CRLF}).
        objHttpRequest:prepare(SUBSTITUTE('X-SAP-LogonToken: "&1"',logonToken) + {&CRLF}).
        objHttpRequest:prepare("Content-Length: 0" + {&CRLF} + {&CRLF}).
        lcReturn = getResult(cType,objHttpRequest:getRequest()).
        objWebiDocuments:readDocuments(lcReturn).
      END.
      WHEN "GET-DOCUMENT" 
      THEN DO:
        IF VALID-HANDLE(objWebiDocuments:getCurrentTT("Document"))
        THEN DO:
          objHttpRequest:prepare(SUBSTITUTE('GET &1/&2 HTTP/1.0' + {&CRLF},baseWebiURL,objWebiDocuments:getCurrentTT("Document")::ID)).
          objHttpRequest:prepare("Accept: application/xml" + {&CRLF}).
          objHttpRequest:prepare(SUBSTITUTE('X-SAP-LogonToken: "&1"',logonToken) + {&CRLF}).
          objHttpRequest:prepare("Content-Length: 0" + {&CRLF} + {&CRLF}).
          lcReturn = getResult(cType,objHttpRequest:getRequest()).
        END.
      END. 
      WHEN "GET-DOCUMENT-PROPERTIES" 
      THEN DO:
        IF VALID-HANDLE(objWebiDocuments:getCurrentTT("Document"))
        THEN DO:
          objHttpRequest:prepare(SUBSTITUTE('GET &1/&2/properties HTTP/1.0' + {&CRLF},baseWebiURL,objWebiDocuments:getCurrentTT("Document")::ID)).
          objHttpRequest:prepare("Accept: application/xml" + {&CRLF}).
          objHttpRequest:prepare(SUBSTITUTE('X-SAP-LogonToken: "&1"',logonToken) + {&CRLF}).
          objHttpRequest:prepare("Content-Length: 0" + {&CRLF} + {&CRLF}).
          lcReturn = getResult(cType,objHttpRequest:getRequest()).
        END.
      END. 
      WHEN "GET-DOCUMENT-DATAPROVIDER" 
      THEN DO:
        IF VALID-HANDLE(objWebiDocuments:getCurrentTT("Document"))
        THEN DO:
          objHttpRequest:prepare(SUBSTITUTE('GET &1/&2/dataproviders HTTP/1.0' + {&CRLF},baseWebiURL,objWebiDocuments:getCurrentTT("Document")::ID)).
          objHttpRequest:prepare("Accept: application/xml" + {&CRLF}).
          objHttpRequest:prepare(SUBSTITUTE('X-SAP-LogonToken: "&1"',logonToken) + {&CRLF}).
          objHttpRequest:prepare("Content-Length: 0" + {&CRLF} + {&CRLF}).
          lcReturn = getResult(cType,objHttpRequest:getRequest()).
        END.
      END. 
      WHEN "GET-DOCUMENT-REPORTS" 
      THEN DO:
        IF VALID-HANDLE(objWebiDocuments:getCurrentTT("Document"))
        THEN DO:
          objHttpRequest:prepare(SUBSTITUTE('GET &1/&2/reports HTTP/1.0' + {&CRLF},baseWebiURL,objWebiDocuments:getCurrentTT("Document")::ID)).
          objHttpRequest:prepare("Accept: application/xml" + {&CRLF}).
          objHttpRequest:prepare(SUBSTITUTE('X-SAP-LogonToken: "&1"',logonToken) + {&CRLF}).
          objHttpRequest:prepare("Content-Length: 0" + {&CRLF} + {&CRLF}).
          lcReturn = getResult(cType,objHttpRequest:getRequest()).
        END.
      END. 
      WHEN "GET-DOCUMENT-REPORT-DETAILS" 
      THEN DO:
        IF VALID-HANDLE(objWebiDocuments:getCurrentTT("Document"))
        THEN DO:
          DEFINE VARIABLE cReport     AS CHARACTER NO-UNDO.
          cReport     = "1".
          objHttpRequest:prepare(SUBSTITUTE('GET &1/&2/reports/&3 HTTP/1.0' + {&CRLF},baseWebiURL,objWebiDocuments:getCurrentTT("Document")::ID,cReport)).
          objHttpRequest:prepare("Accept: application/xml" + {&CRLF}).
          objHttpRequest:prepare(SUBSTITUTE('X-SAP-LogonToken: "&1"',logonToken) + {&CRLF}).
          objHttpRequest:prepare("Content-Length: 0" + {&CRLF} + {&CRLF}).
          lcReturn = getResult(cType,objHttpRequest:getRequest()).
        END.
      END. 
      WHEN "GET-DOCUMENT-REPORT-SPECIFICATION" 
      THEN DO:
        IF VALID-HANDLE(objWebiDocuments:getCurrentTT("Document"))
        THEN DO:
          DEFINE VARIABLE cReportRDS   AS CHARACTER NO-UNDO.
          cReportRDS   = "1".
          objHttpRequest:prepare(SUBSTITUTE('GET &1/&2/reports/&3/specification HTTP/1.0' + {&CRLF},baseWebiURL,objWebiDocuments:getCurrentTT("Document")::ID,cReportRDS)).
          objHttpRequest:prepare("Accept: text/xml" + {&CRLF}).
          objHttpRequest:prepare(SUBSTITUTE('X-SAP-LogonToken: "&1"',logonToken) + {&CRLF}).
          objHttpRequest:prepare("Content-Length: 0" + {&CRLF} + {&CRLF}).
          lcReturn = getResult(cType,objHttpRequest:getRequest(),"<report").
        END.
      END. 
      WHEN "GET-DOCUMENT-XML" 
      THEN DO:
        IF VALID-HANDLE(objWebiDocuments:getCurrentTT("Document"))
        THEN DO:
          objHttpRequest:prepare(SUBSTITUTE('GET &1/&2?dpi=150 HTTP/1.0' + {&CRLF},baseWebiURL,objWebiDocuments:getCurrentTT("Document")::ID,objWebiDocuments:getCurrentTT("Document")::ID + ".XML")).
          objHttpRequest:prepare("Accept: text/xml" + {&CRLF}).
          objHttpRequest:prepare(SUBSTITUTE('X-SAP-LogonToken: "&1"',logonToken) + {&CRLF}).
          objHttpRequest:prepare("Content-Length: 0" + {&CRLF} + {&CRLF}).
          lcReturn = getResult(cType,objHttpRequest:getRequest(),"<document").
        END.
      END. 

      WHEN "GET-UNIVERSES"  
      THEN DO:
        objHttpRequest:prepare(SUBSTITUTE('GET &1?type=unx&&limit=&2 HTTP/1.0' + {&CRLF},baseUniversesURL,2)).
        objHttpRequest:prepare("Accept: application/xml" + {&CRLF}).
        objHttpRequest:prepare(SUBSTITUTE('X-SAP-LogonToken: "&1"',logonToken) + {&CRLF}).
        objHttpRequest:prepare("Content-Length: 0" + {&CRLF} + {&CRLF}).
        lcReturn = getResult(cType,objHttpRequest:getRequest()).
      END.

      OTHERWISE MESSAGE "no case: " cType VIEW-AS ALERT-BOX.
    END CASE.
    
    DELETE OBJECT objHttpRequest.
    
    RETURN lcReturn.

  END METHOD.

  METHOD PRIVATE LONGCHAR getResult(
    cType     AS CHARACTER,
    lcRequest AS LONGCHAR):
    
    RETURN getResult(cType,lcRequest,"<?xml").
    
  END METHOD.  
  
  METHOD PRIVATE LONGCHAR getResult
    (cType     AS CHARACTER,
     lcRequest AS LONGCHAR ,
     cStartXML AS CHARACTER ):
 
    DEFINE VARIABLE objHttpSocket    AS CLASS socket   NO-UNDO.
    DEFINE VARIABLE objHttpResponse  AS CLASS response NO-UNDO.
    DEFINE VARIABLE lcReturn         AS LONGCHAR       NO-UNDO.
    
    objHttpSocket = NEW socket().
    objHttpSocket:connect(pcServer,pnPort).
    
/*    
    MESSAGE cType SKIP STRING(lcrequest)
    VIEW-AS ALERT-BOX.
*/    
    
    IF NOT objHttpSocket:CONNECTED() 
    THEN DO:
    
      MESSAGE 
        SUBSTITUTE("Not connected to server '&1' on port '&2'",pcServer,pnPort) 
        SKIP ERROR-STATUS:GET-MESSAGE(1)
        VIEW-AS ALERT-BOX.
      
      RETURN "".
    END.
    
    IF objHttpSocket:WRITE(lcRequest)
    THEN DO:
      objHttpSocket:setSensitive().
      objHttpResponse = NEW response().
      lcReturn = objHttpResponse:RemoveHeader(objHttpSocket:READ(),cStartXML).
      DELETE OBJECT objHttpResponse.
    END.
    ELSE MESSAGE 'Did not write to socket.' SKIP SUBSTRING(lcRequest,1,MIN(100,LENGTH(lcRequest))) VIEW-AS ALERT-BOX ERROR.
    
    DELETE OBJECT objHttpSocket.
    
    RETURN lcReturn.
    
  END METHOD.
  
END CLASS.
