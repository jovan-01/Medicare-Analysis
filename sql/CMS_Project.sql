SELECT *
FROM chronic;

#Create a labeled copy of the original table
CREATE TABLE labeled_chronic AS
SELECT * FROM chronic;

#Alter column types from INT to VARCHAR to allow string labels

-- Gender and Eligibility
ALTER TABLE labeled_chronic MODIFY BENE_SEX_IDENT_CD VARCHAR(10);
ALTER TABLE labeled_chronic MODIFY DUAL_STUS VARCHAR(20);
ALTER TABLE labeled_chronic MODIFY CC_ALZHDMTA VARCHAR(20);
ALTER TABLE labeled_chronic MODIFY CC_CANCER VARCHAR(20);
ALTER TABLE labeled_chronic MODIFY CC_CHF VARCHAR(25);
ALTER TABLE labeled_chronic MODIFY CC_CHRNKIDN VARCHAR(30);
ALTER TABLE labeled_chronic MODIFY CC_COPD VARCHAR(15);
ALTER TABLE labeled_chronic MODIFY CC_DEPRESSN VARCHAR(20);
ALTER TABLE labeled_chronic MODIFY CC_DIABETES VARCHAR(20);
ALTER TABLE labeled_chronic MODIFY CC_ISCHMCHT VARCHAR(35);
ALTER TABLE labeled_chronic MODIFY CC_OSTEOPRS VARCHAR(20);
ALTER TABLE labeled_chronic MODIFY CC_RA_OA VARCHAR(20);
ALTER TABLE labeled_chronic MODIFY CC_STRKETIA VARCHAR(25);
ALTER TABLE labeled_chronic MODIFY CC_2_OR_MORE VARCHAR(20);

#Apply value labeling

-- Gender
UPDATE labeled_chronic
SET BENE_SEX_IDENT_CD = CASE 
  WHEN BENE_SEX_IDENT_CD = '1' THEN 'Male'
  WHEN BENE_SEX_IDENT_CD = '2' THEN 'Female'
  ELSE 'Unknown'
END;

-- Dual Eligibility
UPDATE labeled_chronic
SET DUAL_STUS = CASE 
  WHEN DUAL_STUS = '1' THEN 'Dual Eligible'
  WHEN DUAL_STUS = '0' THEN 'Not Dual Eligible'
  ELSE 'Unknown'
END;

-- Alzheimer's
UPDATE labeled_chronic
SET CC_ALZHDMTA = CASE 
  WHEN CC_ALZHDMTA = '1.0' THEN 'Has Alzheimer\'s'
  WHEN CC_ALZHDMTA = '0.0' THEN 'No Alzheimer\'s'
  ELSE 'Suppressed'
END;

-- Cancer
UPDATE labeled_chronic
SET CC_CANCER = CASE 
  WHEN CC_CANCER = '1.0' THEN 'Has Cancer'
  WHEN CC_CANCER = '0.0' THEN 'No Cancer'
  ELSE 'Suppressed'
END;

-- CHF
UPDATE labeled_chronic
SET CC_CHF = CASE 
  WHEN CC_CHF = '1' THEN 'Has Heart Failure'
  WHEN CC_CHF = '0' THEN 'No Heart Failure'
  ELSE 'Suppressed'
END;

-- Chronic Kidney Disease
UPDATE labeled_chronic
SET CC_CHRNKIDN = CASE 
  WHEN CC_CHRNKIDN = '1' THEN 'Has Chronic Kidney Disease'
  WHEN CC_CHRNKIDN = '0' THEN 'No Chronic Kidney Disease'
  ELSE 'Suppressed'
END;

-- COPD
UPDATE labeled_chronic
SET CC_COPD = CASE 
  WHEN CC_COPD = '1.0' THEN 'Has COPD'
  WHEN CC_COPD = '0.0' THEN 'No COPD'
  ELSE 'Suppressed'
END;

-- Depression
UPDATE labeled_chronic
SET CC_DEPRESSN = CASE 
  WHEN CC_DEPRESSN = '1.0' THEN 'Has Depression'
  WHEN CC_DEPRESSN = '0.0' THEN 'No Depression'
  ELSE 'Suppressed'
END;

-- Diabetes
UPDATE labeled_chronic
SET CC_DIABETES = CASE 
  WHEN CC_DIABETES = '1' THEN 'Has Diabetes'
  WHEN CC_DIABETES = '0' THEN 'No Diabetes'
  ELSE 'Suppressed'
END;

-- Ischemic Heart Disease
UPDATE labeled_chronic
SET CC_ISCHMCHT = CASE 
  WHEN CC_ISCHMCHT = '1' THEN 'Has Ischemic Heart Disease'
  WHEN CC_ISCHMCHT = '0' THEN 'No Ischemic Heart Disease'
  ELSE 'Suppressed'
END;

-- Osteoporosis
UPDATE labeled_chronic
SET CC_OSTEOPRS = CASE 
  WHEN CC_OSTEOPRS = '1.0' THEN 'Has Osteoporosis'
  WHEN CC_OSTEOPRS = '0.0' THEN 'No Osteoporosis'
  ELSE 'Suppressed'
END;

-- Arthritis
UPDATE labeled_chronic
SET CC_RA_OA = CASE 
  WHEN CC_RA_OA = '1' THEN 'Has Arthritis'
  WHEN CC_RA_OA = '0' THEN 'No Arthritis'
  ELSE 'Suppressed'
END;

-- Stroke/TIA
UPDATE labeled_chronic
SET CC_STRKETIA = CASE 
  WHEN CC_STRKETIA = '1.0' THEN 'Has Stroke/TIA'
  WHEN CC_STRKETIA = '0.0' THEN 'No Stroke/TIA'
  ELSE 'Suppressed'
END;

-- 2+ Conditions
UPDATE labeled_chronic
SET CC_2_OR_MORE = CASE 
  WHEN CC_2_OR_MORE = '1' THEN '2+ Conditions'
  WHEN CC_2_OR_MORE = '0' THEN '<2 Conditions'
  ELSE 'Suppressed'
END;

#Add readable age category label
ALTER TABLE labeled_chronic
ADD COLUMN Age_Category_Label VARCHAR(15);

UPDATE labeled_chronic
SET Age_Category_Label = CASE BENE_AGE_CAT_CD
  WHEN 1 THEN 'Under 65'
  WHEN 2 THEN '65–69'
  WHEN 3 THEN '70–74'
  WHEN 4 THEN '75–79'
  WHEN 5 THEN '80–84'
  WHEN 6 THEN '85+'
  ELSE 'Unknown'
END;

#Drop numeric age column 
ALTER TABLE labeled_chronic
DROP COLUMN BENE_AGE_CAT_CD;

SELECT *
FROM labeled_chronic;

#Avg Cost By Condition and Medicare Part

-- Diabetes
SELECT 'Diabetes' AS `Condition`, 'Part A' AS Medicare_Part,
  AVG(AVE_PA_PAY_PA_EQ_12) AS Avg_Cost
FROM labeled_chronic
WHERE CC_DIABETES = 'Has Diabetes' AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Diabetes', 'Part B',
  AVG(AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12)
FROM labeled_chronic
WHERE CC_DIABETES = 'Has Diabetes'
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Diabetes', 'Part D',
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_DIABETES = 'Has Diabetes' AND AVE_PDE_PD_EQ_12 IS NOT NULL

-- Arthritis
UNION ALL
SELECT 'Arthritis', 'Part A',
  AVG(AVE_PA_PAY_PA_EQ_12)
FROM labeled_chronic
WHERE CC_RA_OA = 'Has Arthritis' AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Arthritis', 'Part B',
  AVG(AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12)
FROM labeled_chronic
WHERE CC_RA_OA = 'Has Arthritis'
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Arthritis', 'Part D',
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_RA_OA = 'Has Arthritis' AND AVE_PDE_PD_EQ_12 IS NOT NULL

-- Chronic Kidney Disease
UNION ALL
SELECT 'Chronic Kidney Disease', 'Part A',
  AVG(AVE_PA_PAY_PA_EQ_12)
FROM labeled_chronic
WHERE CC_CHRNKIDN = 'Has Chronic Kidney Disease' AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Chronic Kidney Disease', 'Part B',
  AVG(AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12)
FROM labeled_chronic
WHERE CC_CHRNKIDN = 'Has Chronic Kidney Disease'
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Chronic Kidney Disease', 'Part D',
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_CHRNKIDN = 'Has Chronic Kidney Disease' AND AVE_PDE_PD_EQ_12 IS NOT NULL

-- Heart Failure
UNION ALL
SELECT 'Heart Failure', 'Part A',
  AVG(AVE_PA_PAY_PA_EQ_12)
FROM labeled_chronic
WHERE CC_CHF = 'Has Heart Failure' AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Heart Failure', 'Part B',
  AVG(AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12)
FROM labeled_chronic
WHERE CC_CHF = 'Has Heart Failure'
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Heart Failure', 'Part D',
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_CHF = 'Has Heart Failure' AND AVE_PDE_PD_EQ_12 IS NOT NULL

-- Ischemic Heart Disease
UNION ALL
SELECT 'Ischemic Heart Disease', 'Part A',
  AVG(AVE_PA_PAY_PA_EQ_12)
FROM labeled_chronic
WHERE CC_ISCHMCHT = 'Has Ischemic Heart Disease' AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Ischemic Heart Disease', 'Part B',
  AVG(AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12)
FROM labeled_chronic
WHERE CC_ISCHMCHT = 'Has Ischemic Heart Disease'
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Ischemic Heart Disease', 'Part D',
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_ISCHMCHT = 'Has Ischemic Heart Disease' AND AVE_PDE_PD_EQ_12 IS NOT NULL

-- Multimorbidity (2+)
UNION ALL
SELECT 'Multimorbidity (2+)', 'Part A',
  AVG(AVE_PA_PAY_PA_EQ_12)
FROM labeled_chronic
WHERE CC_2_OR_MORE = '2+ Conditions' AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Multimorbidity (2+)', 'Part B',
  AVG(AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12)
FROM labeled_chronic
WHERE CC_2_OR_MORE = '2+ Conditions'
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Multimorbidity (2+)', 'Part D',
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_2_OR_MORE = '2+ Conditions' AND AVE_PDE_PD_EQ_12 IS NOT NULL

-- Stroke/TIA
UNION ALL
SELECT 'Stroke/TIA', 'Part A',
  AVG(AVE_PA_PAY_PA_EQ_12)
FROM labeled_chronic
WHERE CC_STRKETIA = 'Has Stroke/TIA' AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Stroke/TIA', 'Part B',
  AVG(AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12)
FROM labeled_chronic
WHERE CC_STRKETIA = 'Has Stroke/TIA'
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Stroke/TIA', 'Part D',
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_STRKETIA = 'Has Stroke/TIA' AND AVE_PDE_PD_EQ_12 IS NOT NULL

-- Osteoporosis
UNION ALL
SELECT 'Osteoporosis', 'Part A',
  AVG(AVE_PA_PAY_PA_EQ_12)
FROM labeled_chronic
WHERE CC_OSTEOPRS = 'Has Osteoporosis' AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Osteoporosis', 'Part B',
  AVG(AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12)
FROM labeled_chronic
WHERE CC_OSTEOPRS = 'Has Osteoporosis'
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Osteoporosis', 'Part D',
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_OSTEOPRS = 'Has Osteoporosis' AND AVE_PDE_PD_EQ_12 IS NOT NULL

-- Depression
UNION ALL
SELECT 'Depression', 'Part A',
  AVG(AVE_PA_PAY_PA_EQ_12)
FROM labeled_chronic
WHERE CC_DEPRESSN = 'Has Depression' AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Depression', 'Part B',
  AVG(AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12)
FROM labeled_chronic
WHERE CC_DEPRESSN = 'Has Depression'
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Depression', 'Part D',
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_DEPRESSN = 'Has Depression' AND AVE_PDE_PD_EQ_12 IS NOT NULL

-- COPD
UNION ALL
SELECT 'COPD', 'Part A',
  AVG(AVE_PA_PAY_PA_EQ_12)
FROM labeled_chronic
WHERE CC_COPD = 'Has COPD' AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL

UNION ALL
SELECT 'COPD', 'Part B',
  AVG(AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12)
FROM labeled_chronic
WHERE CC_COPD = 'Has COPD'
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL

UNION ALL
SELECT 'COPD', 'Part D',
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_COPD = 'Has COPD' AND AVE_PDE_PD_EQ_12 IS NOT NULL

-- Cancer
UNION ALL
SELECT 'Cancer', 'Part A',
  AVG(AVE_PA_PAY_PA_EQ_12)
FROM labeled_chronic
WHERE CC_CANCER = 'Has Cancer' AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Cancer', 'Part B',
  AVG(AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12)
FROM labeled_chronic
WHERE CC_CANCER = 'Has Cancer'
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Cancer', 'Part D',
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_CANCER = 'Has Cancer' AND AVE_PDE_PD_EQ_12 IS NOT NULL

-- Alzheimer's
UNION ALL
SELECT 'Alzheimer''s', 'Part A',
  AVG(AVE_PA_PAY_PA_EQ_12)
FROM labeled_chronic
WHERE CC_ALZHDMTA = 'Has Alzheimer''s' AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Alzheimer''s', 'Part B',
  AVG(AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12)
FROM labeled_chronic
WHERE CC_ALZHDMTA = 'Has Alzheimer''s'
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL

UNION ALL
SELECT 'Alzheimer''s', 'Part D',
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_ALZHDMTA = 'Has Alzheimer''s' AND AVE_PDE_PD_EQ_12 IS NOT NULL;


#Group By Age, Gender, Eligibility
CREATE TEMPORARY TABLE temp_summary AS
SELECT *
FROM (
SELECT
  'Diabetes' AS `Condition`,
  BENE_SEX_IDENT_CD AS Gender,
  Age_Category_Label AS Age_Group,
  DUAL_STUS AS Dual_Eligibility,
  COUNT(*) AS Patient_Count,
  AVG(
    AVE_PA_PAY_PA_EQ_12 + 
    AVE_CA_PAY_PB_EQ_12 + 
    AVE_OP_PAY_PB_EQ_12 + 
    AVE_PDE_CST_PD_EQ_12
  ) AS Avg_Total_Cost
FROM labeled_chronic
WHERE CC_DIABETES = 'Has Diabetes'
  AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_PDE_CST_PD_EQ_12 IS NOT NULL
GROUP BY BENE_SEX_IDENT_CD, Age_Category_Label, DUAL_STUS

UNION ALL

SELECT
  'Arthritis' AS `Condition`,
  BENE_SEX_IDENT_CD AS Gender,
  Age_Category_Label AS Age_Group,
  DUAL_STUS AS Dual_Eligibility,
  COUNT(*) AS Patient_Count,
  AVG(
    AVE_PA_PAY_PA_EQ_12 + 
    AVE_CA_PAY_PB_EQ_12 + 
    AVE_OP_PAY_PB_EQ_12 + 
    AVE_PDE_CST_PD_EQ_12
  ) AS Avg_Total_Cost
FROM labeled_chronic
WHERE CC_DIABETES = 'Has Arthritis'
  AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_PDE_CST_PD_EQ_12 IS NOT NULL
GROUP BY BENE_SEX_IDENT_CD, Age_Category_Label, DUAL_STUS

UNION ALL

SELECT 'Chronic Kidney Disease' AS `Condition`,
  BENE_SEX_IDENT_CD AS Gender,
  Age_Category_Label AS Age_Group,
  DUAL_STUS AS Dual_Eligibility,
  COUNT(*) AS Patient_Count,
  AVG(
    AVE_PA_PAY_PA_EQ_12 +
    AVE_CA_PAY_PB_EQ_12 +
    AVE_OP_PAY_PB_EQ_12 +
    AVE_PDE_CST_PD_EQ_12
  ) AS Avg_Total_Cost
FROM labeled_chronic
WHERE CC_CHRNKIDN = 'Has Chronic Kidney Disease'
  AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_PDE_CST_PD_EQ_12 IS NOT NULL
GROUP BY BENE_SEX_IDENT_CD, Age_Category_Label, DUAL_STUS

UNION ALL

SELECT 'Heart Failure' AS `Condition`,
  BENE_SEX_IDENT_CD AS Gender,
  Age_Category_Label AS Age_Group,
  DUAL_STUS AS Dual_Eligibility,
  COUNT(*) AS Patient_Count,
  AVG(
    AVE_PA_PAY_PA_EQ_12 +
    AVE_CA_PAY_PB_EQ_12 +
    AVE_OP_PAY_PB_EQ_12 +
    AVE_PDE_CST_PD_EQ_12
  ) AS Avg_Total_Cost
FROM labeled_chronic
WHERE CC_CHF = 'Has Heart Failure'
  AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_PDE_CST_PD_EQ_12 IS NOT NULL
GROUP BY BENE_SEX_IDENT_CD, Age_Category_Label, DUAL_STUS

UNION ALL

SELECT 'Ischemic Heart Disease' AS `Condition`,
  BENE_SEX_IDENT_CD AS Gender,
  Age_Category_Label AS Age_Group,
  DUAL_STUS AS Dual_Eligibility,
  COUNT(*) AS Patient_Count,
  AVG(
    AVE_PA_PAY_PA_EQ_12 +
    AVE_CA_PAY_PB_EQ_12 +
    AVE_OP_PAY_PB_EQ_12 +
    AVE_PDE_CST_PD_EQ_12
  ) AS Avg_Total_Cost
FROM labeled_chronic
WHERE CC_ISCHMCHT = 'Has Ischemic Heart Disease'
  AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_PDE_CST_PD_EQ_12 IS NOT NULL
GROUP BY BENE_SEX_IDENT_CD, Age_Category_Label, DUAL_STUS

UNION ALL

SELECT 'Multimorbidity (2+ Conditions)' AS `Condition`,
  BENE_SEX_IDENT_CD AS Gender,
  Age_Category_Label AS Age_Group,
  DUAL_STUS AS Dual_Eligibility,
  COUNT(*) AS Patient_Count,
  AVG(
    AVE_PA_PAY_PA_EQ_12 +
    AVE_CA_PAY_PB_EQ_12 +
    AVE_OP_PAY_PB_EQ_12 +
    AVE_PDE_CST_PD_EQ_12
  ) AS Avg_Total_Cost
FROM labeled_chronic
WHERE CC_2_OR_MORE = '2+ Conditions'
  AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_PDE_CST_PD_EQ_12 IS NOT NULL
GROUP BY BENE_SEX_IDENT_CD, Age_Category_Label, DUAL_STUS

UNION ALL

SELECT 'Stroke/TIA' AS `Condition`,
  BENE_SEX_IDENT_CD AS Gender,
  Age_Category_Label AS Age_Group,
  DUAL_STUS AS Dual_Eligibility,
  COUNT(*) AS Patient_Count,
  AVG(AVE_PA_PAY_PA_EQ_12 + AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12 + AVE_PDE_CST_PD_EQ_12) AS Avg_Total_Cost
FROM labeled_chronic
WHERE CC_STRKETIA = 'Has Stroke/TIA'
  AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_PDE_CST_PD_EQ_12 IS NOT NULL
GROUP BY BENE_SEX_IDENT_CD, Age_Category_Label, DUAL_STUS

UNION ALL

SELECT 'Osteoporosis' AS `Condition`,
  BENE_SEX_IDENT_CD AS Gender,
  Age_Category_Label AS Age_Group,
  DUAL_STUS AS Dual_Eligibility,
  COUNT(*) AS Patient_Count,
  AVG(AVE_PA_PAY_PA_EQ_12 + AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12 + AVE_PDE_CST_PD_EQ_12) AS Avg_Total_Cost
FROM labeled_chronic
WHERE CC_OSTEOPRS = 'Has Osteoporosis'
  AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_PDE_CST_PD_EQ_12 IS NOT NULL
GROUP BY BENE_SEX_IDENT_CD, Age_Category_Label, DUAL_STUS

UNION ALL

SELECT 'Depression' AS `Condition`,
  BENE_SEX_IDENT_CD AS Gender,
  Age_Category_Label AS Age_Group,
  DUAL_STUS AS Dual_Eligibility,
  COUNT(*) AS Patient_Count,
  AVG(AVE_PA_PAY_PA_EQ_12 + AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12 + AVE_PDE_CST_PD_EQ_12) AS Avg_Total_Cost
FROM labeled_chronic
WHERE CC_DEPRESSN = 'Has Depression'
  AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_PDE_CST_PD_EQ_12 IS NOT NULL
GROUP BY BENE_SEX_IDENT_CD, Age_Category_Label, DUAL_STUS

UNION ALL

SELECT 'COPD' AS `Condition`,
  BENE_SEX_IDENT_CD AS Gender,
  Age_Category_Label AS Age_Group,
  DUAL_STUS AS Dual_Eligibility,
  COUNT(*) AS Patient_Count,
  AVG(AVE_PA_PAY_PA_EQ_12 + AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12 + AVE_PDE_CST_PD_EQ_12) AS Avg_Total_Cost
FROM labeled_chronic
WHERE CC_COPD = 'Has COPD'
  AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_PDE_CST_PD_EQ_12 IS NOT NULL
GROUP BY BENE_SEX_IDENT_CD, Age_Category_Label, DUAL_STUS

UNION ALL

SELECT 'Cancer' AS `Condition`,
  BENE_SEX_IDENT_CD AS Gender,
  Age_Category_Label AS Age_Group,
  DUAL_STUS AS Dual_Eligibility,
  COUNT(*) AS Patient_Count,
  AVG(AVE_PA_PAY_PA_EQ_12 + AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12 + AVE_PDE_CST_PD_EQ_12) AS Avg_Total_Cost
FROM labeled_chronic
WHERE CC_CANCER = 'Has Cancer'
  AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_PDE_CST_PD_EQ_12 IS NOT NULL
GROUP BY BENE_SEX_IDENT_CD, Age_Category_Label, DUAL_STUS

UNION ALL

SELECT 'Alzheimer''s' AS `Condition`,
  BENE_SEX_IDENT_CD AS Gender,
  Age_Category_Label AS Age_Group,
  DUAL_STUS AS Dual_Eligibility,
  COUNT(*) AS Patient_Count,
  AVG(AVE_PA_PAY_PA_EQ_12 + AVE_CA_PAY_PB_EQ_12 + AVE_OP_PAY_PB_EQ_12 + AVE_PDE_CST_PD_EQ_12) AS Avg_Total_Cost
FROM labeled_chronic
WHERE CC_ALZHDMTA = 'Has Alzheimer''s'
  AND AVE_PA_PAY_PA_EQ_12 IS NOT NULL
  AND AVE_CA_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_OP_PAY_PB_EQ_12 IS NOT NULL
  AND AVE_PDE_CST_PD_EQ_12 IS NOT NULL
GROUP BY BENE_SEX_IDENT_CD, Age_Category_Label, DUAL_STUS
) AS combined
ORDER BY Avg_Total_Cost DESC;

SELECT * FROM temp_summary;

#Utilization Trends for Each Chronic Condition
SELECT 'Diabetes' AS `Condition`,
  AVG(AVE_IP_ADM_PA_EQ_12) AS IP_Admits,
  AVG(AVE_SNF_DAYS_PA_EQ_12) AS SNF_Days,
  AVG(AVE_CA_VST_PB_EQ_12) AS Dr_Visits,
  AVG(AVE_OP_VST_PB_EQ_12) AS OP_Visits,
  AVG(AVE_PDE_PD_EQ_12) AS Prescriptions
FROM labeled_chronic
WHERE CC_DIABETES = 'Has Diabetes'

UNION ALL

SELECT 'Heart Failure',
  AVG(AVE_IP_ADM_PA_EQ_12),
  AVG(AVE_SNF_DAYS_PA_EQ_12),
  AVG(AVE_CA_VST_PB_EQ_12),
  AVG(AVE_OP_VST_PB_EQ_12),
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_CHF = 'Has Heart Failure'

UNION ALL

SELECT 'Chronic Kidney Disease',
  AVG(AVE_IP_ADM_PA_EQ_12),
  AVG(AVE_SNF_DAYS_PA_EQ_12),
  AVG(AVE_CA_VST_PB_EQ_12),
  AVG(AVE_OP_VST_PB_EQ_12),
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_CHRNKIDN = 'Has Chronic Kidney Disease'

UNION ALL

SELECT 'Ischemic Heart Disease',
  AVG(AVE_IP_ADM_PA_EQ_12),
  AVG(AVE_SNF_DAYS_PA_EQ_12),
  AVG(AVE_CA_VST_PB_EQ_12),
  AVG(AVE_OP_VST_PB_EQ_12),
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_ISCHMCHT = 'Has Ischemic Heart Disease'

UNION ALL

SELECT 'Arthritis',
  AVG(AVE_IP_ADM_PA_EQ_12),
  AVG(AVE_SNF_DAYS_PA_EQ_12),
  AVG(AVE_CA_VST_PB_EQ_12),
  AVG(AVE_OP_VST_PB_EQ_12),
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_RA_OA = 'Has Arthritis'

UNION ALL

SELECT 'Multimorbidity (2+ Conditions)',
  AVG(AVE_IP_ADM_PA_EQ_12),
  AVG(AVE_SNF_DAYS_PA_EQ_12),
  AVG(AVE_CA_VST_PB_EQ_12),
  AVG(AVE_OP_VST_PB_EQ_12),
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_2_OR_MORE = '2+ Conditions'

UNION ALL

SELECT 'Stroke/TIA',
  AVG(AVE_IP_ADM_PA_EQ_12),
  AVG(AVE_SNF_DAYS_PA_EQ_12),
  AVG(AVE_CA_VST_PB_EQ_12),
  AVG(AVE_OP_VST_PB_EQ_12),
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_STRKETIA = 'Has Stroke/TIA'

UNION ALL

SELECT 'Osteoporosis',
  AVG(AVE_IP_ADM_PA_EQ_12),
  AVG(AVE_SNF_DAYS_PA_EQ_12),
  AVG(AVE_CA_VST_PB_EQ_12),
  AVG(AVE_OP_VST_PB_EQ_12),
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_OSTEOPRS = 'Has Osteoporosis'

UNION ALL

SELECT 'Depression',
  AVG(AVE_IP_ADM_PA_EQ_12),
  AVG(AVE_SNF_DAYS_PA_EQ_12),
  AVG(AVE_CA_VST_PB_EQ_12),
  AVG(AVE_OP_VST_PB_EQ_12),
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_DEPRESSN = 'Has Depression'

UNION ALL

SELECT 'COPD',
  AVG(AVE_IP_ADM_PA_EQ_12),
  AVG(AVE_SNF_DAYS_PA_EQ_12),
  AVG(AVE_CA_VST_PB_EQ_12),
  AVG(AVE_OP_VST_PB_EQ_12),
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_COPD = 'Has COPD'

UNION ALL

SELECT 'Cancer',
  AVG(AVE_IP_ADM_PA_EQ_12),
  AVG(AVE_SNF_DAYS_PA_EQ_12),
  AVG(AVE_CA_VST_PB_EQ_12),
  AVG(AVE_OP_VST_PB_EQ_12),
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_CANCER = 'Has Cancer'

UNION ALL

SELECT 'Alzheimer''s',
  AVG(AVE_IP_ADM_PA_EQ_12),
  AVG(AVE_SNF_DAYS_PA_EQ_12),
  AVG(AVE_CA_VST_PB_EQ_12),
  AVG(AVE_OP_VST_PB_EQ_12),
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE CC_ALZHDMTA = 'Has Alzheimer''s'

ORDER BY `Condition`;

#Utilization By Gender
SELECT 'Male' as `Gender`,
  AVG(AVE_IP_ADM_PA_EQ_12) AS IP_Admits,
  AVG(AVE_SNF_DAYS_PA_EQ_12) AS SNF_Days,
  AVG(AVE_CA_VST_PB_EQ_12) AS Dr_Visits,
  AVG(AVE_OP_VST_PB_EQ_12) AS OP_Visits,
  AVG(AVE_PDE_PD_EQ_12) AS Prescriptions
FROM labeled_chronic
WHERE BENE_SEX_IDENT_CD = 'Male'

UNION ALL

SELECT 'Female' as `Gender`,
  AVG(AVE_IP_ADM_PA_EQ_12),
  AVG(AVE_SNF_DAYS_PA_EQ_12),
  AVG(AVE_CA_VST_PB_EQ_12),
  AVG(AVE_OP_VST_PB_EQ_12),
  AVG(AVE_PDE_PD_EQ_12)
FROM labeled_chronic
WHERE BENE_SEX_IDENT_CD = 'Female'
;
  
#Utilization By Age
SELECT 'Under 65' as `Age`,
  AVG(AVE_IP_ADM_PA_EQ_12) AS IP_Admits,
  AVG(AVE_SNF_DAYS_PA_EQ_12) AS SNF_Days,
  AVG(AVE_CA_VST_PB_EQ_12) AS Dr_Visits,
  AVG(AVE_OP_VST_PB_EQ_12) AS OP_Visits,
  AVG(AVE_PDE_PD_EQ_12) AS Prescriptions, 
  (AVG(AVE_IP_ADM_PA_EQ_12) + AVG(AVE_SNF_DAYS_PA_EQ_12) + AVG(AVE_CA_VST_PB_EQ_12) + AVG(AVE_OP_VST_PB_EQ_12) + AVG(AVE_PDE_PD_EQ_12)) as Total_Use
FROM labeled_chronic
WHERE Age_Category_Label = 'Under 65'

UNION ALL

SELECT '65-69' as `Age`,
  AVG(AVE_IP_ADM_PA_EQ_12) AS IP_Admits,
  AVG(AVE_SNF_DAYS_PA_EQ_12) AS SNF_Days,
  AVG(AVE_CA_VST_PB_EQ_12) AS Dr_Visits,
  AVG(AVE_OP_VST_PB_EQ_12) AS OP_Visits,
  AVG(AVE_PDE_PD_EQ_12) AS Prescriptions,
  (AVG(AVE_IP_ADM_PA_EQ_12) + AVG(AVE_SNF_DAYS_PA_EQ_12) + AVG(AVE_CA_VST_PB_EQ_12) + AVG(AVE_OP_VST_PB_EQ_12) + AVG(AVE_PDE_PD_EQ_12)) as Total_Use

FROM labeled_chronic
WHERE Age_Category_Label = '65–69'

UNION ALL

SELECT '70-74' as `Age`,
  AVG(AVE_IP_ADM_PA_EQ_12) AS IP_Admits,
  AVG(AVE_SNF_DAYS_PA_EQ_12) AS SNF_Days,
  AVG(AVE_CA_VST_PB_EQ_12) AS Dr_Visits,
  AVG(AVE_OP_VST_PB_EQ_12) AS OP_Visits,
  AVG(AVE_PDE_PD_EQ_12) AS Prescriptions,
  (AVG(AVE_IP_ADM_PA_EQ_12) + AVG(AVE_SNF_DAYS_PA_EQ_12) + AVG(AVE_CA_VST_PB_EQ_12) + AVG(AVE_OP_VST_PB_EQ_12) + AVG(AVE_PDE_PD_EQ_12)) as Total_Use

FROM labeled_chronic
WHERE Age_Category_Label = '70–74' 

UNION ALL

SELECT '75-79' as `Age`,
  AVG(AVE_IP_ADM_PA_EQ_12) AS IP_Admits,
  AVG(AVE_SNF_DAYS_PA_EQ_12) AS SNF_Days,
  AVG(AVE_CA_VST_PB_EQ_12) AS Dr_Visits,
  AVG(AVE_OP_VST_PB_EQ_12) AS OP_Visits,
  AVG(AVE_PDE_PD_EQ_12) AS Prescriptions,
  (AVG(AVE_IP_ADM_PA_EQ_12) + AVG(AVE_SNF_DAYS_PA_EQ_12) + AVG(AVE_CA_VST_PB_EQ_12) + AVG(AVE_OP_VST_PB_EQ_12) + AVG(AVE_PDE_PD_EQ_12)) as Total_Use
FROM labeled_chronic
WHERE Age_Category_Label = '75–79'

UNION ALL

SELECT '80-84' as `Age`,
  AVG(AVE_IP_ADM_PA_EQ_12) AS IP_Admits,
  AVG(AVE_SNF_DAYS_PA_EQ_12) AS SNF_Days,
  AVG(AVE_CA_VST_PB_EQ_12) AS Dr_Visits,
  AVG(AVE_OP_VST_PB_EQ_12) AS OP_Visits,
  AVG(AVE_PDE_PD_EQ_12) AS Prescriptions,
  (AVG(AVE_IP_ADM_PA_EQ_12) + AVG(AVE_SNF_DAYS_PA_EQ_12) + AVG(AVE_CA_VST_PB_EQ_12) + AVG(AVE_OP_VST_PB_EQ_12) + AVG(AVE_PDE_PD_EQ_12)) as Total_Use

FROM labeled_chronic
WHERE Age_Category_Label = '80–84'

UNION ALL

SELECT '85+' as `Age`,
  AVG(AVE_IP_ADM_PA_EQ_12) AS IP_Admits,
  AVG(AVE_SNF_DAYS_PA_EQ_12) AS SNF_Days,
  AVG(AVE_CA_VST_PB_EQ_12) AS Dr_Visits,
  AVG(AVE_OP_VST_PB_EQ_12) AS OP_Visits,
  AVG(AVE_PDE_PD_EQ_12) AS Prescriptions,
  (AVG(AVE_IP_ADM_PA_EQ_12) + AVG(AVE_SNF_DAYS_PA_EQ_12) + AVG(AVE_CA_VST_PB_EQ_12) + AVG(AVE_OP_VST_PB_EQ_12) + AVG(AVE_PDE_PD_EQ_12)) as Total_Use
FROM labeled_chronic
WHERE Age_Category_Label = '85+'


;