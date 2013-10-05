USE gestione_scuola;

DELETE FROM allocation_didacticalallocation;
DELETE FROM allocation_nondidacticalallocation;
DELETE FROM allocation_allocation;
DELETE FROM auth_user_groups WHERE user_id !=1;
DELETE FROM auth_user WHERE is_superuser !=1;
DELETE FROM account_assignedpolicy;
DELETE FROM account_account;
DELETE FROM sysuser_sysuser;


