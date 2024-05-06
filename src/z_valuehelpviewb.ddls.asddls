@ObjectModel.supportedCapabilities: [#VALUE_HELP_PROVIDER]
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'FieldB1'
@Metadata.ignorePropagatedAnnotations: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'value help A'
define view entity Z_VALUEHELPVIEWB
  as select from zvaluehelpb
{
      @EndUserText.label: 'Field B1'
  key fieldb1,
      @Consumption.valueHelpDefault.binding.usage:#FILTER_AND_RESULT
      @EndUserText.label: 'Field B2'
      @Consumption.valueHelpDefault.display:true
      fieldb2,
      @EndUserText.label: 'Field B3'
      fieldb3
}
