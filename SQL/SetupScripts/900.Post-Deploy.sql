USE [DBName]
GO
PRINT 'enabling all constraints without checking them'
EXEC sp_msforeachtable @command1='print ''?''', @command2='ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all'
GO
PRINT 'enabling trigger PreventAlterToDecisionCriterionSet'
GO
ENABLE TRIGGER PreventAlterToDecisionCriterionSet ON DATABASE;
GO