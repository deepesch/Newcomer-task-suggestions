SELECT
    DATABASE() AS wiki,
    event_userId AS user_id,
    timestamp AS user_registration
FROM log.ServerSideAccountCreation_5487345
WHERE
    wiki = DATABASE() AND
    event_isSelfMade AND
    NOT event_displayMobile AND
    timestamp BETWEEN "20140913" AND "20140920";
