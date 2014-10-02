CREATE TEMPORARY TABLE staging.user_set
SELECT DISTINCT wiki, event_userId, event_setId
FROM TaskRecommendationImpression_9266226;

CREATE TEMPORARY TABLE staging.recommendations_seen
SELECT
    wiki,
    event_userId as user_id,
    SUM(recommendations_seen) AS recommendations_seen
FROM (
    SELECT
        wiki,
        event_userId,
        event_setId,
        MAX(impression.event_offset) + 3 AS recommendations_seen
    FROM ServerSideAccountCreation_5487345 ssac
    INNER JOIN TaskRecommendationImpression_9266226 impression USING
            (wiki, event_userId)
    WHERE
        impression.timestamp BETWEEN
            ssac.timestamp AND
            DATE_FORMAT(DATE_ADD(ssac.timestamp, INTERVAL 7 DAY),
                        "%Y%m%d%H%i%S")
    GROUP BY wiki, event_userId, event_setId
) AS recommendation_sets
GROUP BY wiki, user_id;

CREATE TEMPORARY TABLE staging.recommendations_accepted
SELECT
    wiki,
    event_userId AS user_id,
    COUNT(click.id) AS recommendations_accepted
FROM staging.user_set
INNER JOIN ServerSideAccountCreation_5487345 ssac USING (wiki, event_userId)
INNER JOIN TaskRecommendationClick_9266317 click USING (wiki, event_setId)
WHERE
    click.timestamp BETWEEN
        ssac.timestamp AND
        DATE_FORMAT(DATE_ADD(ssac.timestamp, INTERVAL 7 DAY), "%Y%m%d%H%i%S")
GROUP BY wiki, user_id;

SELECT
    wiki,
    user_id,
    IFNULL(recommendations_seen, 0) AS recommendations_seen,
    IFNULL(recommendations_accepted, 0) AS recommendations_accepted
FROM staging.tr_experimental_user
LEFT JOIN staging.recommendations_seen USING (wiki, user_id)
LEFT JOIN staging.recommendations_accepted USING (wiki, user_id);
