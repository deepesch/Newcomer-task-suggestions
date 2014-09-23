SELECT
    DATABASE() AS wiki,
    log_user AS user_id,
    log_timestamp AS user_registration
FROM logging
WHERE
    log_type = "newusers" AND
    log_action = "create" AND
    log_timestamp BETWEEN "20140913" AND "20140920";
