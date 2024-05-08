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
      //direct value help with field mapping FieldA -> Z_ValueHelpViewA->FieldA1
      @Consumption.valueHelpDefinition: [{
      entity:{ name: 'Z_ValueHelpViewA',
               element:'FieldA1'} }]
      FieldA,
      @UI.lineItem: [{ importance:#HIGH }]
      @UI.selectionField:[{ position:2 }]
      //FieldA3 uses the association _ValueHelpViewA -> FieldA1
      @Consumption.valueHelpDefinition: [{
      association: '_ValueHelpViewA' }]
      FieldA as FieldA3,
      @UI.lineItem: [{ importance:#HIGH }]
      @UI.selectionField:[{ position:3 }]
      //direct value help with additional field mapping 
      //result defines the target field of the value help result as FieldB1 

      @Consumption.valueHelpDefinition: [{
      entity:{ name: 'Z_ValueHelpViewA',
               element:'FieldA1'} ,
      additionalBinding:[{ localElement:'FieldB1',
      element:'FieldA2',
      usage:#RESULT }]}]
      FieldA as FieldA4,
      @UI.lineItem: [{ importance:#HIGH }]
      @UI.selectionField:[{ position:4 }]
      //direct value help without field mapping, using name FieldB1 FieldB -> Z_ValueHelpViewB
      @Consumption.valueHelpDefinition: [{
      entity:{ name: 'Z_ValueHelpViewB'  }}]
      FieldB as FieldB1,
      _ValueHelpViewA
}
