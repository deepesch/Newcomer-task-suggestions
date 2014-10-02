SELECT
    wiki,
    user_id,
    SUM(rev_id IS NOT NULL) AS revisions_saved,
    SUM(page_namespace = 0) AS mainspace_edits,
    SUM(rev_comment LIKE "/* % */%") AS main_section_edits,
    SUM(IF(page_namespace = 0 AND bytes_changed > 0, bytes_changed, 0)) AS
            main_bytes_added ,
    SUM(IF(page_namespace = 0 AND bytes_changed < 0, bytes_changed, 0)) AS
            main_bytes_removed,
    SUM(bytes_changed) AS main_bytes_changed,
    AVG(IF(page_namespace = 0, previous_bytes, NULL)) AS
            mean_mainspace_previous_bytes
FROM staging.tr_experimental_user_revision
GROUP BY wiki, user_id;
