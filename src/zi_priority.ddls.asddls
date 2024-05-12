@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Processing Priority'
@ObjectModel.representativeKey: 'Priority'
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity ZI_Priority as select from DDCDS_CUSTOMER_DOMAIN_VALUE( p_domain_name: 'ZZPRIORITY' )
  association [0..*] to ZI_Priority_Text as _Text on $projection.Priority = _Text.Priority
{
      @ObjectModel.text.association: '_Text'
  key cast( value_low as zzpriority preserving type ) as Priority
  ,
      _Text
}

