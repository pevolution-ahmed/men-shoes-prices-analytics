
SELECT
    row_number() over() as id,
    name,
    brand,
    case 
        when REGEXP_CONTAINS(prices_amountMin, r'[-+]?\d*\.?\d+')
            then cast(REGEXP_EXTRACT(prices_amountMin, r'[-+]?\d*\.?\d+') as FLOAT64)
        else 0
    end as price,
    case 
        when REGEXP_CONTAINS(prices_currency, r'\b(USD|AUD|CAD|EUR|GBP)\b')
            then REGEXP_EXTRACT(prices_currency, r'\b(USD|AUD|CAD|EUR|GBP)\b')
        else "USD"
    end as  currency ,
    case 
        when REGEXP_CONTAINS(prices_dateAdded, r'[0-2][0-9]:[0-5][0-9]:[0-5][0-9]') 
        then cast(prices_dateAdded as TIMESTAMP)
    else NULL
    end as date_added,
    case 
     when REGEXP_CONTAINS(prices_dateSeen, r'[0-2][0-9]:[0-5][0-9]:[0-5][0-9]') 
        then cast(prices_dateSeen as TIMESTAMP)
    else NULL
    end as date_seen ,
    prices_merchant as merchant ,
    case 
    when REGEXP_CONTAINS(prices_condition, r'\b(new|New with tags|New with box|New with box|New without box|Pre-owned|New|Brand New|New with defects)\b')
        then "new"
    when REGEXP_CONTAINS(prices_condition, r'\b(Used|Pre-owned)\b')
        then "used"
    else "Not Specified"
    end as condition ,
    ARRAY(
      SELECT
      case
      when JSON_EXTRACT_SCALAR(x, '$.key') = 'Shoe Size' or  JSON_EXTRACT_SCALAR(x, '$.key') = 'Size'
      then  JSON_QUERY(x,'$.value')
      else 'not exist'
      end
      FROM UNNEST(JSON_QUERY_ARRAY(features, "$"))x
  ) has_size

from men-shoes-sales.ecommerce.sales

