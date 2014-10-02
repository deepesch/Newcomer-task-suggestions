CREATE TABLE tr_experimental_user (
    wiki VARCHAR(50),
    user_id INT,
    user_registration VARBINARY(14)
);
SELECT NOW(), COUNT(*) FROM tr_experimental_user;
