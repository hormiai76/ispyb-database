INSERT INTO SchemaStatus (scriptName, schemaStatus) VALUES ('2024_11_11_DataCollectionGroup_Experimentkind_GphNative.sql', 'ONGOING');

ALTER TABLE
    `DataCollectionGroup`
MODIFY
    COLUMN `experimentType` enum(
        'EM',
        'SAD',
        'SAD - Inverse Beam',
        'OSC',
        'Collect - Multiwedge',
        'MAD',
        'Helical',
        'Multi-positional',
        'Mesh',
        'Burn',
        'MAD - Inverse Beam',
        'Characterization',
        'Dehydration',
        'Still',
        'SSX-Chip',
        'SSX-Jet',
        'LineScan',
        'GphNative'
    );

UPDATE SchemaStatus SET schemaStatus = 'DONE' WHERE scriptName = '2024_11_11_DataCollectionGroup_Experimentkind_GphNative.sql';

