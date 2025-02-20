SELECT MM.ITNO AS m3_id,
       MM.STAT AS active_status,
       MM.ITDS AS name,
       MM.CONO AS internal_comp_num_c,
       MM.ITTY AS item_type_c,
       MM.ITGR AS item_group_c,
       MM.MABU AS make_buy_c,
       MM.ACRF AS acc_control_c,
       MM.BUAR AS area_c,
       MM.ITCL AS product_group_c,
       MM.UNMS AS unit_c,
       MM.ALUC AS alt_unit_c,
       MM.HIE1 AS category_lvl1_id,
       MM.HIE2 AS category_lvl2_id,
       MM.HIE3 AS category_id,
       -- mitbal table is not responding in data lake 
       '' AS expiration_time_c, -- MB.SLDY AS expiration_time_c,
       '' AS manufacturer_code_c, -- COALESCE(MB.SUNO, '') AS manufacturer_code_c,
       COALESCE(ID.SUNM, '') AS manufacturer_name_c,
       ARRAY_JOIN(ARRAY_AGG(CONCAT(MP.ALWQ, ':', MP.POPN)), ', ') AS part_num_c,
       CAST(ROUND(MM.NEWE, 3) AS DECIMAL(10,3)) AS weight,
       CAST(ROUND(MM.GRWE, 3) AS DECIMAL(10,3)) AS weight_brutto_c,
       CAST(ROUND(MM.ILEN, 3) AS DECIMAL(10,3)) AS lenght_c,
       CAST(ROUND(MM.IWID, 3) AS DECIMAL(10,3)) AS width_c,
       CAST(ROUND(MM.IHEI, 3) AS DECIMAL(10,3)) AS height_c,
       MM.RESP AS assigned_user_id,
       MM.FUDS AS description,
       CASE 
           WHEN MM.RGDT IS NOT NULL AND MM.RGDT != 0 
           THEN CONCAT(SUBSTRING(CAST(MM.RGDT AS VARCHAR), 1, 4), '-', 
                       SUBSTRING(CAST(MM.RGDT AS VARCHAR), 5, 2), '-', 
                       SUBSTRING(CAST(MM.RGDT AS VARCHAR), 7, 2), 'T00:00:00') 
           ELSE NULL 
       END AS date_entered,
       CASE 
           WHEN MM.LMDT IS NOT NULL AND MM.LMDT != 0 
           THEN CONCAT(SUBSTRING(CAST(MM.LMDT AS VARCHAR), 1, 4), '-', 
                       SUBSTRING(CAST(MM.LMDT AS VARCHAR), 5, 2), '-', 
                       SUBSTRING(CAST(MM.LMDT AS VARCHAR), 7, 2), 'T00:00:00') 
           ELSE NULL 
       END AS date_modified,
       MM.CHID AS modified_user_id
FROM MITMAS AS MM
LEFT JOIN MITPOP AS MP ON MM.ITNO = MP.ITNO AND MP.ALWT = '2'
--LEFT JOIN MITBAL AS MB ON MM.ITNO = MB.ITNO
LEFT JOIN CIDMAS as ID ON MM.SUNO = ID.SUNO
WHERE MM.CONO = 100
  AND MM.ITTY IN ('T10', 'T11', 'T21', 'T60')
  AND MM.ITNO IN ('10000001', '10000008', '10000044', '10000091', '10000284',
  '10000656', '10003391', '10000635', '10000515', '10002811')
  --AND MB.WHLO = 'C1A'
GROUP BY MM.ITNO, MM.STAT, MM.ITDS, MM.CONO, MM.ITTY, MM.ITGR, MM.MABU, MM.ACRF, 
         MM.BUAR, MM.ITCL, MM.UNMS, MM.ALUC, MM.HIE1, MM.HIE2, MM.HIE3, MM.SUNO,
         MM.NEWE, MM.GRWE, MM.ILEN, MM.IWID, MM.IHEI, MM.RESP, MM.FUDS, MM.RGDT, 
         MM.LMDT, MM.CHID, ID.SUNM
LIMIT 100;