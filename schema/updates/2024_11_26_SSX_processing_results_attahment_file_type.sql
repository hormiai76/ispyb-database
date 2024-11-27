INSERT INTO SchemaStatus (scriptName, schemaStatus) VALUES ('2024_11_26_SSX_processing_results_attahment_file_type.sql', 'ONGOING');

ALTER TABLE SSXProcessingResultAttachment MODIFY COLUMN fileType enum('Result','Real-time processing results','Processing results') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;

UPDATE SSXProcessingResultAttachment SET fileType = 'Real-time processing results' WHERE fileType = 'Result';

ALTER TABLE SSXProcessingResultAttachment MODIFY COLUMN fileType enum('Real-time processing results','Processing results') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;

UPDATE SchemaStatus SET schemaStatus = 'DONE' WHERE scriptName = '2024_11_26_SSX_processing_results_attahment_file_type.sql';

