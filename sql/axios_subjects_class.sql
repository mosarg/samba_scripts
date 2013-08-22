SELECT TMatRmaPst.iMatRmaPstId, TMatRmaPst.iPstId, TMatRmaPst.iMatRmaId, 
        TMatRmaPst.iMatRmaPstOrdine, TMatRmaPst.iOanId, TMatRmaPst.iAdiId, 
        TMatRmaPst.iMatRmaPstnInseg, TMatRmaPst.iCmaId, TMatRmaPst.iTstUstId,
        TMatRmaPst.iMatRmaPstInMedia, TMat.iMatId,
        TMat.sMatLDesc, TMat.sMatCodUser, TOan.iOanSettimanali, TMatRmaPst.iCompAsseId, TAsse.sCompAsseDesc,TMatRmaPst.iMatSIDIId,
        (SELECT mat.SSISMATLDESC    FROM TSISMAT_MATERIE mat   WHERE mat.ISISMATID = TMatRmaPst.IMATSIDIID) AS MateriaSIDI,
        (SELECT mat.SSISMATCODSIDI  FROM TSISMAT_MATERIE mat   WHERE mat.ISISMATID = TMatRmaPst.IMATSIDIID) AS Mat_Cod_SIDI,
        (SELECT sind.SSISINDCODMIN  FROM TPST_PIANISTUDIO pst  INNER JOIN TIND_INDIRIZZO ind ON ind.IINDID = pst.IINDID 
         INNER JOIN TSISIND_INDIRIZZI sind ON sind.ISISINDID = ind.IINDID_P   WHERE pst.IPSTID = TMatRmaPst.IPSTID) AS CodInd
          FROM TMatRmaPst TMatRmaPst    INNER JOIN TMatRma TMatRma 
          ON (TMatRma.iMatRmaId = TMatRmaPst.iMatRmaId AND TMatRma.dDelete IS NULL) INNER JOIN TMat_Materie TMat  
            ON (TMat.iMatId = TMatRma.iMatId AND TMat.dDelete IS NULL)         
                   LEFT JOIN TCompAsse TAsse       ON (TMatRmaPst.iCompAsseId = TAsse.iCompAsseId)
                    LEFT OUTER JOIN TOan_OreAn TOan ON (TOan.iOanId = TMatRmaPst.iOanId AND TOan.dDelete IS NULL)   
                    WHERE (TMatRmaPst.dDelete IS NULL)
                    ORDER BY TMatRmaPst.iMatRmaPstOrdine                                                                      