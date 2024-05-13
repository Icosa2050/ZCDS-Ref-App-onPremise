//@AbapCatalog.sqlViewName: 'DDCDS_CUSTDV'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZDDCDS_CUSTOMER_DOMAIN_VALUE
  with parameters
    p_domain_name : sxco_ad_object_name --abap.char(30)
  as select from dd07l
    inner join   ARS_OBJECTS_ALL_SW_COMP_SCP on  ARS_OBJECTS_ALL_SW_COMP_SCP.program_id  = 'R3TR'
                                             and ARS_OBJECTS_ALL_SW_COMP_SCP.object_type = 'DOMA'
                                             and ARS_OBJECTS_ALL_SW_COMP_SCP.object_name = dd07l.domname
                                             and ARS_OBJECTS_ALL_SW_COMP_SCP.object_name = $parameters.p_domain_name

{
  key dd07l.domname    as domain_name,
  key dd07l.valpos     as value_position,
      dd07l.domvalue_l as value_low,
      dd07l.domvalue_h as value_high
}
where
  dd07l.as4local = 'A'
