with 

source as (
    select * from {{ source('billing_data', 'claims') }} 
),

renamed as (

    select 
        id as claim_id,
        pat_id as patient_id,
        doc_id as doctor_id,
        prac_id as practice_id,
        car_id as carrier_id,
        npi as npi,

        -- numbers
        bill_attmps as total_bill_attempts,

        -- varchsrs
        ClaimNumber as carrier_claim_number,

        -- booleans 
        test as is_test,

        -- dates
        created as created_at,
        firstbill as first_billed_at,
        _fivetran_synced_at as _fivetran_synced_at

    
    from source
)

select 
    *,
    total_bill_attempts > 0 as has_ever_been_billed,
from renamed
where not(is_test)
