@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Value Help View'

@ObjectModel.dataCategory: #VALUE_HELP

@ObjectModel.representativeKey: 'FieldB1'

@ObjectModel.supportedCapabilities: [#VALUE_HELP_PROVIDER]

@Metadata.ignorePropagatedAnnotations: true

//@Search.searchable: true

//@Consumption.ranked:true

define view entity Z_ValueHelpViewC

  as select distinct from t000 

{

      @EndUserText.label: 'Field B1'

      @Consumption.valueHelpDefault.binding.usage: #FILTER_AND_RESULT

  key 'B1_1' as FieldB1,

      @EndUserText.label: 'Field B2'

      @Consumption.valueHelpDefault.display: true

      'B2_1' as FieldB2,

      'B3_1' as FieldB3

//      ,

//      @Search.defaultSearchElement: true

//      @Search.fuzzinessThreshold: 0.8

//      @Search.ranking: #HIGH

//      @Consumption.hidden: true

//      t000.logsys as FieldB4

} 

where t000.mandt = $session.client

union select distinct from t000 

{

  key 'B1_2' as FieldB1,

      'B2_2' as FieldB2, 

      'B3_2' as FieldB3

//      ,

//      t000.logsys as FieldB4

} 

where t000.mandt = $session.client

union select distinct from t000 

{

  key 'B1_3' as FieldB1,

      'B2_3' as FieldB2, 

      'B3_3' as FieldB3

//      ,

//      t000.logsys as FieldB4

}

where t000.mandt = $session.client


