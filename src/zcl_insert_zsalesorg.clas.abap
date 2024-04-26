CLASS zcl_insert_zsalesorg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    METHODS insert_sales_org_ic
      IMPORTING
        out TYPE REF TO if_oo_adt_classrun_out.
    METHODS insert_sales_org_texts
      IMPORTING
        out TYPE REF TO if_oo_adt_classrun_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_insert_zsalesorg IMPLEMENTATION.
  METHOD insert_sales_org_ic.
    DATA: lt_sales_org_ic TYPE TABLE OF zsalesorg.
    DATA: ls_sales_org_ic TYPE zsalesorg.
    SELECT * FROM zsalesorg INTO TABLE @lt_sales_org_ic.
    DELETE zsalesorg FROM TABLE @lt_sales_org_ic.
    IF sy-subrc <> 0.
      out->write( 'error delete' ).
    ENDIF.
    CLEAR ls_sales_org_ic.
    CLEAR lt_sales_org_ic.

    ls_sales_org_ic = VALUE  #(
    client = sy-mandt
    salesorganization = 'CENT'
     ).

    APPEND ls_sales_org_ic TO lt_sales_org_ic.

    ls_sales_org_ic = VALUE  #(
        client = sy-mandt
        salesorganization = 'FILA'
         ).

    APPEND ls_sales_org_ic TO lt_sales_org_ic.

    ls_sales_org_ic = VALUE  #(
        client = sy-mandt
        salesorganization = 'FILB'
         ).

    APPEND ls_sales_org_ic TO lt_sales_org_ic.

    ls_sales_org_ic = VALUE  #(
        client = sy-mandt
        salesorganization = 'FILC'
         ).

    APPEND ls_sales_org_ic TO lt_sales_org_ic.

    INSERT zsalesorg FROM TABLE @lt_sales_org_ic.
    IF sy-subrc = 0.
      COMMIT WORK.
      out->write( lt_sales_org_ic ).
    ELSE.
      out->write( 'error insert' ).
    ENDIF.



  ENDMETHOD.
  METHOD insert_sales_org_texts.
    DATA: lt_sales_org_text TYPE TABLE OF zsalesorgtext.
    DATA: ls_sales_org_text TYPE zsalesorgtext.
    SELECT * FROM zsalesorgtext INTO TABLE @lt_sales_org_text.
    LOOP AT lt_sales_org_text INTO ls_sales_org_text.
      DELETE zsalesorg FROM @ls_sales_org_text.
      IF sy-subrc <> 0.
        out->write( 'error deleting zsalesorg' ).
      ENDIF.
    ENDLOOP.
    CLEAR ls_sales_org_text.
    CLEAR lt_sales_org_text.

    ls_sales_org_text = VALUE  #(
    salesorganization = 'CENT'
    language = 'E'
    vtext = 'Central Sales Organization'
     ).

    APPEND ls_sales_org_text TO lt_sales_org_text.

    ls_sales_org_text = VALUE  #(
        salesorganization = 'FILA'
        language = 'E'
        vtext = 'Sales Organization A'
         ).

    APPEND ls_sales_org_text TO lt_sales_org_text.

    ls_sales_org_text = VALUE  #(
        salesorganization = 'FILB'
        language = 'E'
        vtext = 'Sales Organization B'
         ).

    APPEND ls_sales_org_text TO lt_sales_org_text.

    ls_sales_org_text = VALUE  #(
        salesorganization = 'FILC'
        language = 'E'
        vtext = 'Sales Organization C'
         ).

    APPEND ls_sales_org_text TO lt_sales_org_text.

    INSERT zsalesorgtext FROM TABLE @lt_sales_org_text.
    IF sy-subrc <> 0.
      out->write( 'error insert zsalesorgtext' ).
    ELSE.
      COMMIT WORK.
      out->write( lt_sales_org_text ).
    ENDIF.



  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    insert_sales_org_ic( out = out ).
    insert_sales_org_texts( out = out ).
  ENDMETHOD.
ENDCLASS.
