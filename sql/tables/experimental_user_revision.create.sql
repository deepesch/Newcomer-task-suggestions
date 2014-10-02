CREATE TABLE tr_experimental_user_revision (
    wiki VARCHAR(50),
    user_id INT,
    rev_id INT,
    rev_comment VARBINARY(255),
    page_namespace INT,
    bytes_changed INT,
    previous_bytes INT
);
SELECT COUNT(*), NOW() FROM tr_experimental_user_revision;
