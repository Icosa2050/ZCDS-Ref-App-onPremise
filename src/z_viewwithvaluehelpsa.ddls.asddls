@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'View with Value Helps'

@Metadata.ignorePropagatedAnnotations: true

define view entity Z_ViewWithValueHelpsA

  as select distinct from t000

{

  key 'K1' as KeyField,

      'A1_1' as FieldA,

      'B1_1' as FieldB

} union select distinct from t000

{

  key 'K2' as KeyField,

      'A1_3' as FieldA,

      'B1_3' as FieldB

} union select distinct from t000

{

  key 'K3' as KeyField,

      'A1_3' as FieldA,

      'B1_3' as FieldB

} 


