@Metadata.ignorePropagatedAnnotations: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Sales Order Item'
@Metadata.allowExtensions: true
@AbapCatalog.extensibility: {
extensible:true,
elementSuffix:'ZSI',
allowNewDatasources:false,
dataSources: ['_Extension'],
quota: {
maximumFields:1000,
maximumBytes:10000
}

}
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZR_SalesOrderItem_IC
  as select from ZI_SalesOrderItem
  association [0..1] to ZE_SalesOrderItem as _Extension on  $projection.SalesOrder     = _Extension.SalesOrder

                                                        and $projection.SalesOrderItem = _Extension.SalesOrderItem

{
  key SalesOrder,
  key SalesOrderItem,
      Product,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      OrderQuantity,
      OrderQuantityUnit,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      NetAmount,
      TransactionCurrency,
      CreationDate,
      CreationDateTime,
      CreatedByUser,
      LastChangeDateTime,
      LastChangedByUser,
      /* Associations */
      _Product,
      _SalesOrder,
      _ScheduleLine,
      _Extension

}
