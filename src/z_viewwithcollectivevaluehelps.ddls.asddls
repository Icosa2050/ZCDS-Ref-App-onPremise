@AccessControl.authorizationCheck: #NOT_REQUIRED

@ObjectModel.supportedCapabilities: [#COLLECTIVE_VALUE_HELP]

@EndUserText.label: 'View with Collective Value Helps'

@Metadata.ignorePropagatedAnnotations: true

define view entity Z_ViewWithCollectiveValueHelps 

  as select from Z_ViewWithValueHelpsA

{

  key KeyField,

  @Consumption.valueHelpDefinition:[{entity:{name:'Z_CollectiveValueHelp',element:'FieldD1'}}]

  FieldA,

  @Consumption.valueHelpDefinition:[{entity:{name:'Z_ValueHelpViewA',element:'FieldA1'}},

                                    {entity:{name:'Z_ValueHelpViewC',element:'FieldC1'}}]

  FieldA as FieldA2

}


