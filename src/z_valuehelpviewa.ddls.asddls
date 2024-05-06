@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'FieldA1'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'value help A'
define view entity Z_ValueHelpViewA
  as select from zvaluehelpa
{
  @EndUserText.label: 'Field A1'
  key fielda1,
  @Consumption.valueHelpDefinition:[{
  entity: { name:'Z_ValueHelpViewB',
  element: 'FieldB1' } }]
  @EndUserText.label: 'Field A2'
  fielda2
}
