INSERT INTO SchemaStatus (scriptName, schemaStatus) VALUES ('2026_07_17_Proposal_Data_Deletion_Request.sql', 'ONGOING');

CREATE TABLE `ProposalDataDeletionRequest` (
  `proposalDataDeletionRequestId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `proposalId` int(10) unsigned NOT NULL,
  `requestedBy` int(10) unsigned NOT NULL,
  `approvedBy` int(10) unsigned DEFAULT NULL,
  `retentionDate` date DEFAULT NULL,
  `comments` varchar(2000) DEFAULT NULL,
  `status` enum('REQUESTED','APPROVED','REJECTED','COMPLETED','CANCELLED') NOT NULL DEFAULT 'REQUESTED',
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `approvalDate` timestamp NULL DEFAULT NULL,
  `completedDate` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`proposalDataDeletionRequestId`),
  KEY `idx_pddr_proposal` (`proposalId`),
  KEY `idx_pddr_requested_by` (`requestedBy`),
  KEY `idx_pddr_approved_by` (`approvedBy`),
  KEY `idx_pddr_status` (`status`),
  CONSTRAINT `fk_proposal_data_deletion_request_approved_by` FOREIGN KEY (`approvedBy`) REFERENCES `Person` (`personId`),
  CONSTRAINT `fk_proposal_data_deletion_request_proposal` FOREIGN KEY (`proposalId`) REFERENCES `Proposal` (`proposalId`),
  CONSTRAINT `fk_proposal_data_deletion_request_requested_by` FOREIGN KEY (`requestedBy`) REFERENCES `Person` (`personId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

UPDATE SchemaStatus SET schemaStatus = 'DONE' WHERE scriptName = '2026_07_17_Proposal_Data_Deletion_Request.sql';

