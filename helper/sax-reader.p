/*------------------------------------------------------------------------
    File        : sax-reader.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Bernd Martin Dot Net
    Created     : Fri Aug 29 08:42:28 CEST 2014
    Notes       :
  ----------------------------------------------------------------------*/
ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.*.
USING WEBI.*.

DEFINE INPUT PARAMETER pObjReader AS CLASS helper.saxReader NO-UNDO .


PROCEDURE Characters:
  DEFINE VARIABLE cData AS CHARACTER NO-UNDO.
  
    DEFINE INPUT  PARAMETER pmCharData  AS MEMPTR   NO-UNDO.
    DEFINE INPUT  PARAMETER piNumChars  AS INTEGER  NO-UNDO.

    pObjReader:Characters (pmCharData, piNumChars).

END PROCEDURE.

PROCEDURE EndElement:
    DEFINE INPUT PARAMETER pcNamespaceURI AS CHARACTER NO-UNDO .
    DEFINE INPUT PARAMETER pcLocalName    AS CHARACTER NO-UNDO .
    DEFINE INPUT PARAMETER pcName         AS CHARACTER NO-UNDO .

    pObjReader:EndElement (pcNamespaceURI, pcLocalName, pcName) .

END PROCEDURE .

PROCEDURE StartElement:
    DEFINE INPUT PARAMETER pcNamespaceURI AS CHARACTER NO-UNDO .
    DEFINE INPUT PARAMETER pcLocalName    AS CHARACTER NO-UNDO .
    DEFINE INPUT PARAMETER pcName         AS CHARACTER NO-UNDO .
    DEFINE INPUT PARAMETER phAttributes   AS HANDLE    NO-UNDO .

    pObjReader:StartElement (pcNamespaceURI, pcLocalName, pcName, phAttributes) .

END PROCEDURE.
