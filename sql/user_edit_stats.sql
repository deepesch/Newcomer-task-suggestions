SELECT
    wiki,
    user_id,
    IFNULL(accepted_edits, 0) AS accepted_edits
FROM staging.tr_experimental_user
LEFT JOIN (
    SELECT
        DATABASE() AS wiki,
        event_userId AS user_id,
        COUNT(*) AS accepted_edits
    FROM (
        SELECT DISTINCT wiki, event_userId, event_setId
        FROM log.TaskRecommendationImpression_9266226
        WHERE wiki = DATABASE()
    ) AS user_set
    INNER JOIN log.ServerSideAccountCreation_5487345 ssac USING
            (wiki, event_userId)
    INNER JOIN log.TaskRecommendationClick_9266317 click USING
            (event_setId)
    INNER JOIN revision ON
        rev_user = event_userId AND
        rev_page = click.event_pageId AND
        rev_timestamp >= click.timestamp
    WHERE
        ssac.wiki = DATABASE() AND
        rev_timestamp BETWEEN
            ssac.timestamp AND
            DATE_FORMAT(DATE_ADD(ssac.timestamp, INTERVAL 7 DAY),
                        "%Y%m%d%H%i%S")
    GROUP BY wiki, user_id
) AS accepted_edits USING (wiki, user_id);
