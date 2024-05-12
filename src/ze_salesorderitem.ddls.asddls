@AccessControl.authorizationCheck: #PRIVILEGED_ONLY
@EndUserText.label: 'extension'
@Metadata.ignorePropagatedAnnotations: true
@AbapCatalog.extensibility:{
extensible:true,
elementSuffix: 'ZSI',
dataSources: ['Persistence'],
allowNewDatasources:false,
quota: { 
maximumFields:1000,
maximumBytes: 10000
}


}
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType:#EXTENSION
define view entity ZE_SalesOrderItem as select from zsalesorderitem as Persistence
{
key Persistence.salesorder as SalesOrder,
key Persistence.salesorderitem as SalesOrderItem
    
}
