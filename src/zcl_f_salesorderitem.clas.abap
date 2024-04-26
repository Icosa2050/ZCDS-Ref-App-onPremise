CLASS zcl_f_salesorderitem DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
    INTERFACES if_sadl_exit_filter_transform .
    INTERFACES if_sadl_exit_sort_transform .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_F_SALESORDERITEM IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_F_SALESORDERITEM->IF_SADL_EXIT_CALC_ELEMENT_READ~CALCULATE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_ORIGINAL_DATA               TYPE        STANDARD TABLE
* | [--->] IT_REQUESTED_CALC_ELEMENTS     TYPE        TT_ELEMENTS
* | [<-->] CT_CALCULATED_DATA             TYPE        STANDARD TABLE
* | [!CX!] CX_SADL_EXIT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_sadl_exit_calc_element_read~calculate.
    LOOP AT it_original_data ASSIGNING FIELD-SYMBOL(<salesorderitem>).
      ASSIGN COMPONENT 'NETAMOUNT'
        OF STRUCTURE <salesorderitem>
        TO FIELD-SYMBOL(<netamount>).
      CHECK sy-subrc = 0.
      CHECK <netamount> IS INITIAL.
      ASSIGN COMPONENT 'ORDERISFREEOFCHARGE'
        OF STRUCTURE ct_calculated_data[ sy-tabix ]
        TO FIELD-SYMBOL(<orderisfreeofcharge>).
      CHECK sy-subrc = 0.
      <orderisfreeofcharge> = abap_true.
    ENDLOOP.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_F_SALESORDERITEM->IF_SADL_EXIT_CALC_ELEMENT_READ~GET_CALCULATION_INFO
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_REQUESTED_CALC_ELEMENTS     TYPE        TT_ELEMENTS
* | [--->] IV_ENTITY                      TYPE        STRING
* | [<---] ET_REQUESTED_ORIG_ELEMENTS     TYPE        TT_ELEMENTS
* | [!CX!] CX_SADL_EXIT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    INSERT CONV #('NETAMOUNT') INTO TABLE et_requested_orig_elements.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_F_SALESORDERITEM->IF_SADL_EXIT_FILTER_TRANSFORM~MAP_ATOM
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY                      TYPE        STRING
* | [--->] IV_ELEMENT                     TYPE        SADL_ENTITY_ELEMENT
* | [--->] IV_OPERATOR                    TYPE        STRING
* | [--->] IV_VALUE                       TYPE        STRING
* | [<-()] RO_CONDITION                   TYPE REF TO IF_SADL_COND_PROVIDER_GENERIC
* | [!CX!] CX_SADL_EXIT_FILTER_NOT_SUPP
* | [!CX!] CX_SADL_EXIT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_sadl_exit_filter_transform~map_atom.
    ASSERT iv_entity = 'ZC_SALESORDERITEMTP'.
    ASSERT iv_element = 'ORDERISFREEOFCHARGE'.
    CASE iv_operator.
      WHEN if_sadl_exit_filter_transform~co_operator-equals.
        IF iv_value = abap_true.
          DATA(isfree) = abap_true.
        ELSE.
          isfree = abap_false.
        ENDIF.
      WHEN if_sadl_exit_filter_transform~co_operator-greater_than.
        IF iv_value = abap_true.
          RETURN.
        ELSE.
          isfree = abap_true.
        ENDIF.
      WHEN if_sadl_exit_filter_transform~co_operator-less_than.
        IF iv_value = abap_true.
          isfree = abap_false.
        ELSE.
          RETURN.
        ENDIF.
      WHEN if_sadl_exit_filter_transform~co_operator-is_null.
        ASSERT 1 = 0. "may never happen
      WHEN if_sadl_exit_filter_transform~co_operator-covers_pattern.
        ASSERT 1 = 0. "may never happen
    ENDCASE.
    DATA(condition) = cl_sadl_cond_prov_factory_pub=>create_simple_cond_factory( ).
    IF isfree = abap_true.
      condition->element( iv_name = 'NETAMOUNT' )->equals( iv_value = 0 ).
    ELSE.
      condition->element( iv_name = 'NETAMOUNT' )->greater_than( iv_value = 0 ).
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_F_SALESORDERITEM->IF_SADL_EXIT_SORT_TRANSFORM~MAP_ELEMENT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY                      TYPE        STRING
* | [--->] IV_ELEMENT                     TYPE        STRING
* | [<---] ET_SORT_ELEMENTS               TYPE        TT_SORT_ELEMENTS
* | [!CX!] CX_SADL_EXIT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_sadl_exit_sort_transform~map_element.
    ASSERT iv_entity = 'ZC_SALESORDERITEMTP'.
    ASSERT iv_element = 'ORDERISFREEOFCHARGE'.
    APPEND VALUE #( name = 'NETAMOUNT' reverse = abap_true ) TO et_sort_elements.
  ENDMETHOD.
ENDCLASS.


