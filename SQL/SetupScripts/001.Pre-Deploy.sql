USE [DBName]
GO
PRINT 'disabling trigger PreventAlterToDecisionCriterionSet'
GO
DISABLE TRIGGER PreventAlterToDecisionCriterionSet ON DATABASE;
GO
PRINT 'disabling all constraints'
EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT all'
GO