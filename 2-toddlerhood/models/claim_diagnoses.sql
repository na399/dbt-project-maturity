-- you realized this was repeated, and could be moved into it's own model!

select 
    claim_id,
    pos as diagnosis_number,
    icd10 as icd_10_code,
    icd10desc as icd_10_code_descrip,
    split(icd10, '.')[offset(0)] as parent_icd10
from {{ source('billing_data', 'claim_diagnosis') }} 
