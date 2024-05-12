@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Priority Description'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'Priority'

/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity ZI_Priority_Text as select from dd07t 
  association [1..1] to ZI_Priority as _Priority
    on $projection.Priority = _Priority.Priority
  association [0..1] to I_Language as _Language      
    on $projection.Language = _Language.Language
{
      @ObjectModel.foreignKey.association: '_Language'
      @Semantics.language: true
  key cast( dd07t.ddlanguage as spras preserving type ) as Language, 
      @ObjectModel.foreignKey.association: '_Priority'
      @ObjectModel.text.element: ['PriorityText']
  key cast( dd07t.domvalue_l as zzpriority ) as Priority,
      @Semantics.text: true
      cast( dd07t.ddtext as zzprioritytext ) as PriorityText,
      _Priority,
      _Language
} 
where dd07t.domname  = 'ZZPRIORITY'
  and dd07t.as4local = 'A'
  and dd07t.as4vers  = '0000'

