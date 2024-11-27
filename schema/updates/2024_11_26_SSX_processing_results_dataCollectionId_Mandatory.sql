INSERT INTO SchemaStatus (scriptName, schemaStatus) VALUES ('2024_11_26_SSX_processing_results_dataCollectionId_Mandatory.sql', 'ONGOING');

ALTER TABLE SSXProcessingResult MODIFY COLUMN dataCollectionId int(11) unsigned NOT NULL;

UPDATE SchemaStatus SET schemaStatus = 'DONE' WHERE scriptName = '2024_11_26_SSX_processing_results_dataCollectionId_Mandatory.sql';

