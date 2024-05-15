extend view entity ZE_SalesOrderItem with
association [0..1] to ZI_Priority as _ZZPriorityZSI 
on $projection.ZZPriorityZSI = _ZZPriorityZSI.Priority
{
  @ObjectModel.foreignKey.association: '_ZZPriorityZSI'
  Persistence.zzpriorityzsi as ZZPriorityZSI,
  Persistence.zzpriority2zsi as ZZPriority2ZSI,
  _ZZPriorityZSI

}
