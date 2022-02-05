-- if it's not abundantly clear this is a completely fabricated query on data that exists nowhere

select 
    c.id as claim_id,
    p.name_f || ' ' || p.name_l as pat_name,
    p.dob,
    d.name as doctor_name,
    d.npi,
    (select max(specialty) from `dbt-maturity`.ehr_data.doc_specialties ds where ds.doc_id = d.id) as spec_name,
    prim_diag.icd_10_code as primary_diag,
    prim_diag.icd_10_code_descrip as primary_diag_desc,
    sec_diag.icd_10_code as sec_diag,
    sec_diag.icd_10_code_descrip as sec_diag_desc,
    c.ClaimNumber,
    ca.total_claim_amnt,
    ca.paid_amnt
from 
    `dbt-maturity`.ehr_data.patients p
    join `dbt-maturity`.billing_data.claims c
        on p.id = c.pat_id
    left join (
        select 
            cl.claim_id, 
            sum(chrgamnt) total_claim_amnt,
            sum(paid_amnt) paid_amnt
        from `dbt-maturity`.billing_data.claim_line cl
        where status in ('billed', 'adjudicated', 'closed')
        group by 1
    ) ca 
        on c.id = ca.claim_id
    left join (
        select 
            claim_id,
            icd10 as icd_10_code,
            icd10desc as icd_10_code_descrip,
            split(icd10, '.')[offset(0)] as parent_icd10
        from `dbt-maturity`.billing_data.claim_diagnosis
        where pos = 1
    ) as prim_diag
    on c.id = prim_diag.claim_id
    left join (
        select 
            claim_id,
            icd10 as icd_10_code,
            icd10desc as icd_10_code_descrip,
            split(icd10, '.')[offset(0)] as parent_icd10
        from `dbt-maturity`.billing_data.claim_diagnosis
        where pos = 2
    ) as sec_diag
    on c.id = sec_diag.claim_id
    left join `dbt-maturity`.ehr_data.doctors d
        on c.doc_id = d.id 

where c.test = false 
and p.email not like '%@test-patient.com'
and c.bill_attmps > 0