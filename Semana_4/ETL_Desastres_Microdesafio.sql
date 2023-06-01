create schema desastres_bde;

-- 2. crear tabla clima futuro global
CREATE TABLE desastres_bde.clima
(anio INT NOT NULL PRIMARY KEY,
Temperatura FLOAT NOT NULL,
Oxigeno FLOAT NOT NULL);

-- Insertar valores manualmente
INSERT INTO desastres_bde.clima VALUES (2023, 22.5,230);
INSERT INTO desastres_bde.clima VALUES (2024, 22.7,228.6);
INSERT INTO desastres_bde.clima VALUES (2025, 22.9,227.5);
INSERT INTO desastres_bde.clima VALUES (2026, 23.1,226.7);
INSERT INTO desastres_bde.clima VALUES (2027, 23.2,226.4);
INSERT INTO desastres_bde.clima VALUES (2028, 23.4,226.2);
INSERT INTO desastres_bde.clima VALUES (2029, 23.6,226.1);
INSERT INTO desastres_bde.clima VALUES (2030, 23.8,225.1);

-- 3. crear tabla desastres proyectados globales
CREATE TABLE desastres_bde.desastres
(anio INT NOT NULL PRIMARY KEY,
Tsunamis INT NOT NULL,
Olas_Calor INT NOT NULL,
Terremotos INT NOT NULL,
Erupciones INT NOT NULL,
Incendios INT NOT NULL);

-- Insertar valores manualmente
INSERT INTO desastres_bde.desastres VALUES (2023, 2,15, 6,7,50);
INSERT INTO desastres_bde.desastres VALUES (2024, 1,12, 8,9,46);
INSERT INTO desastres_bde.desastres VALUES (2025, 3,16, 5,6,47);
INSERT INTO desastres_bde.desastres VALUES (2026, 4,12, 10,13,52);
INSERT INTO desastres_bde.desastres VALUES (2027, 5,12, 6,5,41);
INSERT INTO desastres_bde.desastres VALUES (2028, 4,18, 3,2,39);
INSERT INTO desastres_bde.desastres VALUES (2029, 2,19, 5,6,49);
INSERT INTO desastres_bde.desastres VALUES (2030, 4,20, 6,7,50);

-- 4. crear tabla muertes proyectadas por rangos de edad
CREATE TABLE desastres_bde.muertes
(anio INT NOT NULL PRIMARY KEY,
R_Menor15 INT NOT NULL,
R_15_a_30 INT NOT NULL,
R_30_a_45 INT NOT NULL,
R_45_a_60 INT NOT NULL,
R_M_a_60 INT NOT NULL);

-- Insertar valores manualmente
INSERT INTO desastres_bde.muertes VALUES (2023, 1000,1300, 1200,1150,1500);
INSERT INTO desastres_bde.muertes VALUES (2024, 1200,1250, 1260,1678,1940);
INSERT INTO desastres_bde.muertes VALUES (2025, 987,1130, 1160,1245,1200);
INSERT INTO desastres_bde.muertes VALUES (2026, 1560,1578, 1856,1988,1245);
INSERT INTO desastres_bde.muertes VALUES (2027, 1002,943, 1345,1232,986);
INSERT INTO desastres_bde.muertes VALUES (2028, 957,987, 1856,1567,1756);
INSERT INTO desastres_bde.muertes VALUES (2029, 1285,1376, 1465,1432,1236);
INSERT INTO desastres_bde.muertes VALUES (2030, 1145,1456, 1345,1654,1877);

-- 5. Crear base de datos para alojar resumenes de estadisticas
CREATE schema DESASTRES_BDE_dw;

CREATE TABLE DESASTRES_BDE_dw.DESASTRES_FINAL
(Cuatrenio varchar(20) NOT NULL PRIMARY KEY,
Temp_AVG FLOAT NOT NULL, Oxi_AVG FLOAT NOT NULL,
T_Tsunamis INT NOT NULL, T_OlasCalor INT NOT NULL,
T_Terremotos INT NOT NULL, T_Erupciones INT NOT NULL, 
T_Incendios INT NOT NULL,M_Jovenes_AVG FLOAT NOT NULL,
M_Adutos_AVG FLOAT NOT NULL,M_Ancianos_AVG FLOAT NOT NULL);


--6. Query del ETL



CREATE PROCEDURE pETL_Desastres ()
LANGUAGE plpgsql
as
$$
begin
DELETE FROM DESASTRES_BDE_DW.DESASTRES_FINAL;
INSERT INTO DESASTRES_BDE_DW.DESASTRES_FINAL
SELECT 
  x.Cuatrenio, 
  AVG(x.Temperatura) AS Temp_AVG, 
  AVG(x.NivelOxigeno) AS Oxi_AVG, 
  SUM(x.Tsunamis) AS T_Tsunamis, 
  SUM(x.OlasCalor) AS T_OlasCalor, 
  SUM(x.Terremotos) AS T_Terremotos, 
  SUM(x.Erupciones) AS T_Erupciones, 
  SUM(x.Incendios) AS T_Incendios, 
  AVG(x.Muertes_Jovenes) as M_Jovenes_AVG, 
  AVG(x.Muertes_Adultos) as M_Adultos_AVG, 
  AVG(x.Muertes_Ancianos) as M_Ancianos_AVG 
FROM 
  (
    SELECT 
      CASE WHEN c.anio < 2026 THEN '2023-2026' ELSE '2027-2030' END AS Cuatrenio, 
      c.temperatura as Temperatura, 
      c.oxigeno as NivelOxigeno, 
      d.Tsunamis as Tsunamis, 
      d.Olas_calor as OlasCalor, 
      d.Terremotos as Terremotos, 
      d.Erupciones as Erupciones, 
      d.Incendios as Incendios, 
      (m.R_Menor15 + m.R_15_a_30) as Muertes_Jovenes, 
      (m.R_30_a_45 + m.R_45_a_60) as Muertes_Adultos, 
      m.R_M_a_60 as Muertes_Ancianos
    FROM 
      desastres_bde.clima as c 
      JOIN desastres_bde.desastres as d ON c.anio = d.anio 
      JOIN desastres_bde.muertes as m ON c.anio = m.anio
  ) x 
GROUP BY 
  x.Cuatrenio;
end
$$;

CALL pETL_Desastres();




-- 8. Verificar que se tiene el resultado
SELECT * FROM DESASTRES_BDE_DW.DESASTRES_FINAL;