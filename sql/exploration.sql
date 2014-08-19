SELECT 
    event_returnTo,
    count(*)
FROM ServerSideAccountCreation_5487345
WHERE
    wiki = "enwiki" AND
    timestamp BETWEEN "20140716" AND "20140723" AND
    event_returnTo IS NOT NULL AND
    event_returnTo NOT LIKE "%:%" AND
    event_returnTo != "Main Page"
GROUP BY event_returnTo
ORDER BY COUNT(*) DESC
LIMIT 20;
