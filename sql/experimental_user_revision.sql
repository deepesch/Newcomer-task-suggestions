SELECT
    DATABASE() AS wiki,
    user_id,
    revision.rev_id,
    revision.rev_comment LIKE "/* % */%" AS section_comment,
    page_namespace,
    CAST(revision.rev_len AS INT) -
        CAST(IFNULL(parent.rev_len, 0) AS INT) AS bytes_changed,
    IFNULL(parent.rev_len, 0) AS previous_bytes
FROM staging.tr_experimental_user
INNER JOIN revision FORCE INDEX (user_timestamp) ON
    user_id = rev_user AND
    revision.rev_timestamp BETWEEN
        user_registration AND
        DATE_FORMAT(DATE_ADD(user_registration, INTERVAL 7 DAY),
                    "%Y%m%d%H%i%S")
LEFT JOIN revision parent ON
    parent.rev_id = revision.rev_parent_id
INNER JOIN page ON
    revision.rev_page = page_id
WHERE
    wiki = DATABASE();
