INSERT INTO SchemaStatus (scriptName, schemaStatus) VALUES ('2024_11_13_SSX_processing_results_nbCrystals.sql', 'ONGOING');

ALTER TABLE SSXProcessingResult ADD nbCrystals INT NULL COMMENT 'Number of crystals';

UPDATE SchemaStatus SET schemaStatus = 'DONE' WHERE scriptName = '2024_11_13_SSX_processing_results_nbCrystals.sql';

