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



define view entity ZI_SalesOrderItem
  as select from zsalesorderitem

  association [0..1] to ZI_Product                as _Product    on  $projection.Product = _Product.Product

  composition [0..*] of ZI_SalesOrderScheduleLine as _ScheduleLine

  association        to parent ZI_SalesOrder      as _SalesOrder on  $projection.SalesOrder = _SalesOrder.SalesOrder
  association [0..1] to ZE_SalesOrderItem         as _Extension  on  $projection.SalesOrder     = _Extension.SalesOrder

                                                                 and $projection.SalesOrderItem = _Extension.SalesOrderItem


{
  key salesorder          as SalesOrder,
  key salesorderitem      as SalesOrderItem,
      product             as Product,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      @EndUserText.label: 'Order Quantity'
      orderquantity       as OrderQuantity,
      @EndUserText.label: 'Order Quantity Unit'
      orderquantityunit   as OrderQuantityUnit,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      netamount           as NetAmount,
      transactioncurrency as TransactionCurrency,
      @Semantics.systemDateTime.createdAt: true
      creationdate        as CreationDate,
      createdbyuser       as CreatedByUser,
      creationdatetime    as CreationDateTime,
      lastchangedatetime  as LastChangeDateTime,
      lastchangedbyuser   as LastChangedByUser,
      _SalesOrder,
      _Product,
      _ScheduleLine,
      _Extension

}
