@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'view with Value Help'
@Metadata.ignorePropagatedAnnotations: true

define view entity Z_VIEWWITHVALUEHELPSB
  as select from Z_ViewWithValueHelpsA
  association [0..1] to Z_ValueHelpViewA as _ValueHelpViewA on $projection.FieldA3 = _ValueHelpViewA.fielda1
{
      @UI.lineItem: [{ importance:#HIGH }]
  key KeyField,
      @UI.lineItem: [{ importance:#HIGH }]
      @UI.selectionField:[{ position:1 }]
      @Consumption.valueHelpDefinition: [{
      entity:{ name: 'Z_ValueHelpViewA',
               element:'FieldA1'} }]
      FieldA,
      @UI.lineItem: [{ importance:#HIGH }]
      @UI.selectionField:[{ position:2 }]
      @Consumption.valueHelpDefinition: [{
      association: '_ValueHelpViewA' }]
      FieldA as FieldA3,
      @UI.lineItem: [{ importance:#HIGH }]
      @UI.selectionField:[{ position:3 }]
      @Consumption.valueHelpDefinition: [{
      entity:{ name: 'Z_ValueHelpViewA',
               element:'FieldA1'} ,
      additionalBinding:[{ localElement:'FieldB1',
      element:'FieldA2',
      usage:#RESULT }]}]
      FieldA as FieldA4,
      @UI.lineItem: [{ importance:#HIGH }]
      @UI.selectionField:[{ position:4 }]
      @Consumption.valueHelpDefinition: [{
      entity:{ name: 'Z_ValueHelpViewB',
               element:'FieldA1' }}]
      FieldB as FieldB1,
      _ValueHelpViewA
}
