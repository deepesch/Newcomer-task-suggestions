SELECT DISTINCT
    REPLACE(return_to, " ", "_") AS title
FROM (
    SELECT
        event_returnTo AS return_to
    FROM ServerSideAccountCreation_5487345
    WHERE
        wiki = "enwiki" AND
        timestamp BETWEEN "20140716" AND "20140723" AND
        event_returnTo IS NOT NULL AND
        event_returnTo NOT LIKE "%:%" AND
        event_returnTo != "Main Page"
    ORDER BY RAND()
    LIMIT 201
) AS sample
