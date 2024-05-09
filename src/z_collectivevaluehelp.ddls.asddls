@ObjectModel.supportedCapabilities:[#COLLECTIVE_VALUE_HELP]
@ObjectModel.collectiveValueHelp.for.element: 'FieldD1'
@EndUserText.label: 'collective value help'
define abstract entity Z_CollectiveValueHelp
{
      @Consumption.valueHelpDefinition: [
       {entity:{name:'Z_ValueHelpViewA', element : 'FieldA1'}},
       {entity:{name:'Z_ValueHelpViewC', element : 'FieldC1'}}]
  key FieldD1 : abap.char(4);
}
