INSERT INTO SchemaStatus (scriptName, schemaStatus) VALUES ('2024_11_26_Beamline_service_permissions.sql', 'ONGOING');

INSERT INTO Permission (permissionId,`type`,description)
	VALUES (104,'bl_service','Beamline service');

UPDATE SchemaStatus SET schemaStatus = 'DONE' WHERE scriptName = '2024_11_26_Beamline_service_permissions.sql';

