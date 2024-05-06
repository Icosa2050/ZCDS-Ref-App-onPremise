@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'employee projection'
define root view entity ZHC_HIERARCHICALEMPLOYEE 
provider contract transactional_query
as projection on ZHI_EmployeeRelation
{
key Employee,
_Employee,
Manager,
_Manager : redirected to ZHC_HierarchicalEmployee,
_Employee.EmployeeName,
_Employee.PartTimePercent
}
