use Y2_C4_PROD

Select cast(GHE_DATECREATION AS DATE) Fecha, COUNT(*) Total  from  JOURNALEVENT
  GROUP BY cast(GHE_DATECREATION AS DATE) ORDER BY  cast(GHE_DATECREATION AS DATE)  desc