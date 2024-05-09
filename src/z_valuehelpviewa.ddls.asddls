@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Value Help View'

@ObjectModel.dataCategory: #VALUE_HELP

@ObjectModel.representativeKey: 'FieldA1'

@ObjectModel.supportedCapabilities: [#VALUE_HELP_PROVIDER]

@Metadata.ignorePropagatedAnnotations: true

define view entity Z_ValueHelpViewA

  as select distinct from t000 

{

      @EndUserText.label: 'Field A1'

  key 'A1_1' as FieldA1,

      @Consumption.valueHelpDefinition: [{ entity : {name    : 'Z_ValueHelpViewB',

                                           element : 'FieldB1'} }]

      @EndUserText.label: 'Field A2'

      'B1_1' as FieldA2

} union select distinct from t000 

{

  key 'A1_2' as FieldA1,

      'B1_1' as FieldA2

} union select distinct from t000 

{

  key 'A1_3' as FieldA1,

      'B1_3' as FieldA2

} 


