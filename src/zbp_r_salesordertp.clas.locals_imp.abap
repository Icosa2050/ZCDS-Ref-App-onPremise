CLASS lsc_zr_salesordertp DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zr_salesordertp IMPLEMENTATION.

  METHOD save_modified.
    DATA lt_changed TYPE TABLE FOR EVENT zr_salesordertp~changed.
    DATA lt_deleted TYPE TABLE FOR EVENT zr_salesordertp~deleted.

    IF create-salesorder IS NOT INITIAL.
      RAISE ENTITY EVENT zr_salesordertp~created
        FROM CORRESPONDING #( create-salesorder MAPPING eventraiseddatetime = creationdatetime ).
    ENDIF.

    lt_deleted = CORRESPONDING #( delete-salesorder ).

    LOOP AT update-salesorder ASSIGNING FIELD-SYMBOL(<ls_salesorder>).
      IF <ls_salesorder>-deletionindicator = abap_true.
        APPEND VALUE #( salesorder = <ls_salesorder>-salesorder ) TO lt_deleted.
      ELSE.
        APPEND VALUE #( salesorder = <ls_salesorder>-salesorder ) TO lt_changed.
      ENDIF.
    ENDLOOP.

    IF lt_changed IS NOT INITIAL.
      RAISE ENTITY EVENT zr_salesordertp~changed FROM lt_changed.
    ENDIF.

    IF lt_deleted IS NOT INITIAL.
      RAISE ENTITY EVENT zr_salesordertp~deleted FROM lt_deleted.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_salesorderscheduleline DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS verifyquantityunit FOR VALIDATE ON SAVE
      IMPORTING ls_keys FOR salesorderscheduleline~verifyquantityunit.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING ls_keys REQUEST requested_features FOR salesorderscheduleline RESULT result.

ENDCLASS.

CLASS lhc_salesorderscheduleline IMPLEMENTATION.

  METHOD verifyquantityunit.
    READ ENTITY IN LOCAL MODE zr_salesorderschedulelinetp
         FIELDS ( orderquantity orderquantityunit )
         WITH CORRESPONDING #( ls_keys )
         RESULT DATA(salesorderschedulelines).
    SELECT unitofmeasure FROM i_unitofmeasure WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @salesorderschedulelines
      WHERE unitofmeasure = @salesorderschedulelines-orderquantityunit ORDER BY PRIMARY KEY INTO TABLE @DATA(lt_uoms).
    IF sy-subrc = 0.
      LOOP AT salesorderschedulelines ASSIGNING FIELD-SYMBOL(<ls_salesorderscheduleline>).
        APPEND VALUE #( %tky        = <ls_salesorderscheduleline>-%tky
                        %state_area = 'VERIFYQUANTITY' )
          TO reported-salesorderscheduleline.

        IF <ls_salesorderscheduleline>-orderquantity IS NOT INITIAL AND
             <ls_salesorderscheduleline>-orderquantityunit IS INITIAL.
          APPEND VALUE #( %tky = <ls_salesorderscheduleline>-%tky ) TO failed-salesorderscheduleline.
          APPEND VALUE #( %tky                      = <ls_salesorderscheduleline>-%tky
                          %msg                      = NEW zcm_salesorder(
                                                            textid   = zcm_salesorder=>uom_initial
                                                            severity = if_abap_behv_message=>severity-error
                                                      )
                          %element-orderquantityunit = if_abap_behv=>mk-on
                          %state_area                = 'VERIFYQUANTITY' )
            TO reported-salesorderscheduleline.
        ENDIF.
        IF <ls_salesorderscheduleline>-orderquantityunit IS NOT INITIAL.
          APPEND VALUE #( %tky = <ls_salesorderscheduleline>-%tky ) TO failed-salesorderscheduleline.
          APPEND VALUE #( %tky                      = <ls_salesorderscheduleline>-%tky
                          %msg                      = NEW zcm_salesorder(
                              textid          = zcm_salesorder=>uom_does_not_exist
                              unit_of_measure = <ls_salesorderscheduleline>-orderquantityunit
                              severity        = zcm_salesorder=>if_abap_behv_message~severity-error
                              )
                          %element-orderquantityunit = if_abap_behv=>mk-on
                          %state_area                = 'VERIFYQUANTITY' )
                  TO reported-salesorderscheduleline.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_salesorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS earlynumbering_cba_item FOR NUMBERING
      IMPORTING entities FOR CREATE salesorder\_item.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING ls_keys REQUEST requested_authorizations FOR salesorder RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR salesorder RESULT result.

    METHODS delete FOR MODIFY
      IMPORTING ls_keys FOR ACTION salesorder~delete.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR salesorder RESULT result.

    METHODS createfromquote FOR MODIFY
      IMPORTING ls_keys FOR ACTION salesorder~createfromquote.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING ls_keys REQUEST requested_features FOR salesorder RESULT result.
    METHODS getnumberofitems FOR READ
      IMPORTING ls_keys FOR FUNCTION salesorder~getnumberofitems RESULT result.
    METHODS getsalesorder FOR READ IMPORTING ls_keys FOR FUNCTION salesorder~getsalesorder RESULT result.
    METHODS calculatetotalnetamount FOR DETERMINE ON MODIFY
      IMPORTING ls_keys FOR salesorder~calculatetotalnetamount.
    METHODS verifysoldtoparty FOR VALIDATE ON SAVE
      IMPORTING ls_keys FOR salesorder~verifysoldtoparty.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE salesorder.
    METHODS lock FOR LOCK
      IMPORTING ls_keys FOR LOCK salesorder.


ENDCLASS.

CLASS lhc_salesorder IMPLEMENTATION.


  METHOD getsalesorder.
    READ ENTITY IN LOCAL MODE zr_salesordertp
    ALL FIELDS
    WITH CORRESPONDING #( ls_keys )
    RESULT DATA(salesorders)
    FAILED failed.

    READ ENTITY IN LOCAL MODE zr_salesordertp
    BY \_item
    ALL FIELDS
    WITH CORRESPONDING #( ls_keys )
    RESULT DATA(salesorderitems).

    READ ENTITY IN LOCAL MODE zr_salesorderitemtp
    BY \_scheduleline
    ALL FIELDS
    WITH CORRESPONDING #( salesorderitems )
    RESULT DATA(salesorderslines).

    LOOP AT ls_keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      READ TABLE salesorders ASSIGNING FIELD-SYMBOL(<ls_salesorder>) WITH KEY id COMPONENTS %tky = <ls_key>-%tky.
      IF sy-subrc = 0.

        "authority check
        AUTHORITY-CHECK OBJECT 'Z_VBAK_VK'
        ID 'ACTVT' FIELD '03'
        ID 'ZAUART' FIELD <ls_salesorder>-salesordertype.
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <ls_salesorder>-%tky
          %fail-cause = if_abap_behv=>cause-unauthorized
          ) TO failed-salesorder.
          CONTINUE.
        ENDIF.
        APPEND VALUE #( salesorder = <ls_salesorder>-salesorder )
        TO result
        ASSIGNING FIELD-SYMBOL(<ls_result>).
        <ls_result>-%param = CORRESPONDING #( <ls_salesorder> ).
        LOOP AT salesorderitems ASSIGNING FIELD-SYMBOL(<ls_salesorderitem>) USING KEY
        entity WHERE ( salesorder = <ls_salesorder>-salesorder ).
          APPEND CORRESPONDING #( <ls_salesorderitem> ) TO <ls_result>-%param-_items
          ASSIGNING FIELD-SYMBOL(<ls_result_item>).
          LOOP AT salesorderslines ASSIGNING FIELD-SYMBOL(<ls_salesorderline>) USING KEY entity
          WHERE salesorder = <ls_salesorderitem>-salesorder
          AND salesorderitem = <ls_salesorderitem>-salesorderitem.
            APPEND CORRESPONDING #( <ls_salesorderline> ) TO <ls_result_item>-_schedulelines.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    READ ENTITIES OF zr_salesordertp IN LOCAL MODE
    ENTITY salesorder
    FIELDS ( salesordertype )
    WITH CORRESPONDING #( ls_keys )
    RESULT DATA(lt_salesorders)
    FAILED failed.

    LOOP AT lt_salesorders ASSIGNING FIELD-SYMBOL(<ls_salesorder>).
      "TODO is this right?
      IF requested_authorizations-%update = if_abap_behv=>mk-on
      OR requested_authorizations-%action-edit = if_abap_behv=>mk-on.
        AUTHORITY-CHECK OBJECT 'Z_VBAK_VK'
          ID 'ACTVT' FIELD '02'.
        "ID 'AUART' FIELD <ls_salesorder>-salesordertype.
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky    = <ls_salesorder>-%tky
                          %update = if_abap_behv=>auth-unauthorized
                        ) TO result.
          APPEND VALUE #( %tky = <ls_salesorder>-%tky
                          %msg = NEW zcm_salesorder(
                                       textid     = zcm_salesorder=>no_auth_update
                                       salesorder = <ls_salesorder>-salesorder
                                       severity   = zcm_salesorder=>if_abap_behv_message~severity-error
                                 )
                        ) TO reported-salesorder.
        ENDIF.
      ENDIF.
      IF requested_authorizations-%delete = if_abap_behv=>mk-on.
        AUTHORITY-CHECK OBJECT 'Z_VBAK_VK'
          ID 'ACTVT' FIELD '06'.
        "ID 'AUART' FIELD <ls_salesorder>-salesordertype.
        "ID 'AUART' FIELD <ls_salesorder>-salesordertype.
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <ls_salesorder>-%tky
                           %delete = if_abap_behv=>auth-unauthorized
                        ) TO result.
          APPEND VALUE #( %tky = <ls_salesorder>-%tky
                           %msg = NEW zcm_salesorder(
                                       textid     = zcm_salesorder=>no_auth_delete
                                       salesorder = <ls_salesorder>-salesorder
                                       severity   = zcm_salesorder=>if_abap_behv_message~severity-error
                                 )
                        ) TO reported-salesorder.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_item.

    READ ENTITIES OF zr_salesordertp IN LOCAL MODE
    ENTITY salesorder BY \_item
    FIELDS ( salesorderitem )
    WITH CORRESPONDING #( entities )
    RESULT DATA(lt_sales_order_items)
    FAILED failed.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_sales_order>).
      "get highest item from sales order items of a sales order

      DATA(max_item_id) = REDUCE #( INIT max = CONV zposnr_ic( '000000' )
                          FOR sales_order_item IN lt_sales_order_items USING KEY entity
                          WHERE ( salesorder = <ls_sales_order>-salesorder )
                          NEXT max = COND zposnr_ic( WHEN sales_order_item-salesorderitem > max
                          THEN sales_order_item-salesorderitem
                          ELSE max )
                          ).
    ENDLOOP.
    "assign sales order item id
    LOOP AT <ls_sales_order>-%target ASSIGNING
    FIELD-SYMBOL(<ls_sales_order_item>).
      APPEND CORRESPONDING #( <ls_sales_order_item> ) TO
      mapped-salesorderitem
      ASSIGNING FIELD-SYMBOL(<ls_mapped_sales_order_item>).
      IF <ls_sales_order_item>-salesorderitem IS INITIAL.
        max_item_id += 1.
        <ls_sales_order_item>-salesorderitem = max_item_id.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      AUTHORITY-CHECK OBJECT 'Z_VBAK_VK'
        ID 'ACTVT' FIELD '01'
        ID 'ZKVORG' DUMMY.
      IF sy-subrc <> 0.
        result-%create = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %global = if_abap_behv=>mk-on
                        %msg = NEW zcm_salesorder(
                                     textid   = zcm_salesorder=>no_auth_create
                                     severity = zcm_salesorder=>if_abap_behv_message~severity-error
                               )
                      ) TO reported-salesorder.

      ENDIF.
      IF requested_authorizations-%update = if_abap_behv=>mk-on.
        AUTHORITY-CHECK OBJECT 'Z_VBAK_VK'
          ID 'ACTVT' FIELD '02'
          ID 'ZVKORG' DUMMY.
        IF sy-subrc <> 0.
          result-%update = if_abap_behv=>auth-unauthorized.
          APPEND VALUE #( %global = if_abap_behv=>mk-on
                                  %msg = NEW zcm_salesorder(
                                       textid   = zcm_salesorder=>no_auth_update
                                       severity = zcm_salesorder=>if_abap_behv_message~severity-error
                                 )
                        ) TO reported-salesorder.
        ENDIF.
      ENDIF.
      IF requested_authorizations-%delete = if_abap_behv=>mk-on.
        AUTHORITY-CHECK OBJECT 'Z_VBAK_VK'
          ID 'ACTVT' FIELD '06'
          ID 'ZVKORG' DUMMY.
        IF sy-subrc <> 0.
          result-%delete = if_abap_behv=>auth-unauthorized.
          APPEND VALUE #( %global = if_abap_behv=>mk-on
                                  %msg = NEW zcm_salesorder(
                                       textid   = zcm_salesorder=>no_auth_delete
                                       severity = zcm_salesorder=>if_abap_behv_message~severity-error
                                 )
                        ) TO reported-salesorder.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD delete.
    READ ENTITY IN LOCAL MODE zr_salesordertp
       FIELDS ( deliverystatus deletionindicator )
       WITH CORRESPONDING #( ls_keys )
       RESULT DATA(salesorders)
       FAILED failed.

    DATA update TYPE TABLE FOR UPDATE zr_salesordertp\\salesorder.
    DATA delete TYPE TABLE FOR DELETE zr_salesordertp\\salesorder.

    LOOP AT salesorders ASSIGNING FIELD-SYMBOL(<ls_salesorder>).
      IF <ls_salesorder>-deliverystatus = space OR <ls_salesorder>-deliverystatus = 'A'.
        "physically delete sales orders with delivery status space or A
        APPEND VALUE #( %tky = <ls_salesorder>-%tky ) TO delete.
      ELSEIF <ls_salesorder>-deletionindicator = abap_false.
        "logically delete sales orders with delivery status B or C
        APPEND VALUE #( %tky                       = <ls_salesorder>-%tky
                        deletionindicator          = abap_true
                        %control-deletionindicator = if_abap_behv=>mk-on ) TO update.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITY IN LOCAL MODE zr_salesordertp
      UPDATE FROM update
      DELETE FROM delete
      FAILED failed
      REPORTED reported.
  ENDMETHOD.

  METHOD get_global_features.
    DATA(l_salesordercreatwitchedeof) = abap_false.
    "read system configuration to check if creation is allowed
    "...
    IF l_salesordercreatwitchedeof = abap_true.
      result = CORRESPONDING #( requested_features ).
    ENDIF.
  ENDMETHOD.

  METHOD createfromquote.
    DATA ls_keys_base TYPE TABLE FOR ACTION IMPORT zr_salesordertp~createfromquote.
    LOOP AT ls_keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      APPEND VALUE #( %cid                = <ls_key>-%cid
"                      %param-%is_draft    = <ls_key>-%param-%is_draft
"TODO salesquotes and salesquote do not match???
*                      %param-_salesquotes = VALUE #( ( <ls_key>-%param-salesquote ) )
                    ) TO ls_keys_base.
    ENDLOOP.
    "added local mode
    MODIFY ENTITY IN LOCAL MODE zr_salesordertp
      EXECUTE createfromquote FROM ls_keys_base
      MAPPED   DATA(mapped_base)
      FAILED   DATA(failed_base)
      REPORTED DATA(reported_base).
    mapped   = CORRESPONDING #( DEEP mapped_base ).
    failed   = CORRESPONDING #( DEEP failed_base ).
    reported = CORRESPONDING #( DEEP reported_base ).
    "TODO implement
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITY IN LOCAL MODE zr_salesordertp
      FIELDS ( deliverystatus )
      WITH CORRESPONDING #( ls_keys )
      RESULT DATA(salesorders)
      FAILED failed.

    LOOP AT salesorders ASSIGNING FIELD-SYMBOL(<ls_salesorder>).
      IF <ls_salesorder>-deliverystatus = 'C'.
        APPEND VALUE #( %tky      = <ls_salesorder>-%tky
                        %features = CORRESPONDING #( requested_features ) ) TO result.
        "      ELSEIF <ls_salesorder>-%is_draft = if_abap_behv=>mk-on.
        "        APPEND VALUE #( %tky      = <ls_salesorder>-%tky
        "                        %features = VALUE #( %action-delete = if_abap_behv=>mk-on ) ) TO result.
      ENDIF.
    ENDLOOP.
    "TODO implement
  ENDMETHOD.

  METHOD getnumberofitems.
    READ ENTITY zr_salesordertp ##NO_LOCAL_MODE
    BY \_item
    FROM CORRESPONDING #( ls_keys )
    RESULT DATA(salesorderitems)
    FAILED failed.

    LOOP AT ls_keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      READ TABLE failed-salesorder TRANSPORTING NO FIELDS WITH KEY id COMPONENTS %tky = <ls_key>-%tky.
      CHECK sy-subrc <> 0.
      APPEND VALUE #( %tky = <ls_key>-%tky
                           %param = REDUCE #( INIT count = 0
                                FOR salesorderitem IN salesorderitems
                                    WHERE (  %tky = <ls_key>-%tky ) ##PRIMKEY
                                NEXT count += count ) ) TO result.

    ENDLOOP.
  ENDMETHOD.

  METHOD calculatetotalnetamount.
    READ ENTITY IN LOCAL MODE zr_salesordertp BY \_item
      FIELDS (  netamount transactioncurrency )
      WITH CORRESPONDING #( ls_keys )
      RESULT DATA(salesorderitems).
    DATA lt_updates TYPE TABLE FOR UPDATE zr_salesordertp.
    LOOP AT salesorderitems ASSIGNING FIELD-SYMBOL(<ls_salesorderitem>).
      READ TABLE lt_updates ASSIGNING FIELD-SYMBOL(<ls_update>)
      WITH KEY id COMPONENTS %tky = CORRESPONDING #( <ls_salesorderitem>-%tky ).
      IF sy-subrc <> 0.
        APPEND VALUE #( %tky = CORRESPONDING #( <ls_salesorderitem>-%tky ) )
        TO lt_updates ASSIGNING <ls_update>.
      ENDIF.
      <ls_update>-transactioncurrency = <ls_salesorderitem>-transactioncurrency.
      <ls_update>-netamount += <ls_salesorderitem>-netamount.
    ENDLOOP.

    MODIFY ENTITY IN LOCAL MODE zr_salesordertp
    UPDATE FIELDS (  netamount transactioncurrency ) WITH lt_updates.
  ENDMETHOD.

  METHOD verifysoldtoparty.
    READ ENTITY IN LOCAL MODE zr_salesordertp
    FIELDS ( soldtoparty )
    WITH CORRESPONDING #( ls_keys )
    RESULT DATA(salesorders).

    SELECT customer FROM zi_customer WITH PRIVILEGED ACCESS
    FOR ALL ENTRIES IN @salesorders
    WHERE customer = @salesorders-soldtoparty ORDER BY PRIMARY KEY
    INTO TABLE @DATA(lt_customers).
    IF sy-subrc = 0.
      LOOP AT salesorders ASSIGNING FIELD-SYMBOL(<ls_salesorder>).
        APPEND VALUE #( %tky = <ls_salesorder>-%tky
                           %state_area = 'VERIFYSOLDTO' ) TO reported-salesorder.
        IF <ls_salesorder>-soldtoparty IS INITIAL.
          APPEND VALUE #( %tky = <ls_salesorder>-%tky ) TO failed-salesorder.
          APPEND VALUE #( %tky = <ls_salesorder>-%tky
                          %msg = NEW zcm_salesorder(
                                       textid   = zcm_salesorder=>sold_to_party_does_not_exist
                                       sold_to_party = <ls_salesorder>-soldtoparty
                                       severity = zcm_salesorder=>if_abap_behv_message~severity-error
                                 )
          %element-soldtoparty = if_abap_behv=>mk-on
                             %state_area = 'VERIFYSOLDTO' ) TO reported-salesorder.
        ELSE.
          READ TABLE lt_customers TRANSPORTING NO FIELDS WITH KEY customer = <ls_salesorder>-soldtoparty.
          IF sy-subrc <> 0.
            APPEND VALUE #( %tky = <ls_salesorder>-%tky ) TO failed-salesorder.
            APPEND VALUE #( %tky = <ls_salesorder>-%tky
                            %msg = NEW zcm_salesorder(
                                         textid   = zcm_salesorder=>sold_to_party_does_not_exist
                                         sold_to_party = <ls_salesorder>-soldtoparty
                                         severity = zcm_salesorder=>if_abap_behv_message~severity-error
                                   )
            %element-soldtoparty = if_abap_behv=>mk-on
            %state_area = 'VERIFYSOLDTO' ) TO reported-salesorder.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD precheck_update.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_salesorder>)
    WHERE %control-salesordertype = if_abap_behv=>mk-on.
      AUTHORITY-CHECK OBJECT 'Z_VBAK_VK'
      ID 'ACTVT' FIELD '02'
      ID 'ZVKORG' FIELD <ls_salesorder>-salesordertype.
      IF sy-subrc <> 0.
        APPEND VALUE #( %cid = <ls_salesorder>-%cid_ref
                %tky = <ls_salesorder>-%tky
                %fail-cause = if_abap_behv=>cause-unspecific
                %update = if_abap_behv=>mk-on
                )
        TO failed-salesorder.
        APPEND VALUE #( %tky = <ls_salesorder>-%tky
        %msg = NEW zcm_salesorder(
                           textid = zcm_salesorder=>no_auth_update_type
                           salesorder = <ls_salesorder>-salesorder
                           severity = zcm_salesorder=>if_abap_behv_message~severity-error
                )
        ) TO reported-salesorder.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD lock.

  ENDMETHOD.

ENDCLASS.
CLASS lhc_salesorderitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_schedulein FOR NUMBERING
      IMPORTING entities FOR CREATE salesorderitem\_scheduleline.
    "METHODS rba_Confirmedscheduleline FOR READ
    "  IMPORTING ls_keys_rba FOR READ salesorderItem\_Confirmedscheduleline FULL result_requested
    "RESULT result LINK association_links.
    "

    "METHODS rba_Requestedscheduleline FOR READ
    "  IMPORTING ls_keys_rba FOR READ salesorderItem\_Requestedscheduleline FULL result_requested RESULT
    "result LINK association_links.

    "METHODS cba_Confirmedscheduleline FOR MODIFY
    "  IMPORTING entities_cba FOR CREATE salesorderItem\_Confirmedscheduleline.

    "METHODS cba_Requestedscheduleline FOR MODIFY
    "  IMPORTING entities_cba FOR CREATE salesorderItem\_Requestedscheduleline.

    METHODS delete FOR MODIFY
      IMPORTING ls_keys FOR ACTION salesorderitem~delete.
    METHODS copy FOR MODIFY
      IMPORTING ls_keys FOR ACTION salesorderitem~copy RESULT result.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING ls_keys REQUEST requested_authorizations FOR salesorderitem RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR salesorderitem RESULT result.
    METHODS calculatetotalamount FOR DETERMINE ON MODIFY
      IMPORTING ls_keys FOR salesorderitem~calculatetotalamount.
    "METHODS CalculateNetAmount FOR DETERMINE ON SAVE
    "  IMPORTING ls_keys FOR salesorderItem~CalculateNetAmount.
    METHODS verifyproduct FOR VALIDATE ON SAVE
      IMPORTING ls_keys FOR salesorderitem~verifyproduct.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING ls_keys REQUEST requested_features FOR salesorderitem RESULT result.

ENDCLASS.

CLASS lhc_salesorderitem IMPLEMENTATION.

  METHOD earlynumbering_cba_schedulein.
    READ ENTITIES OF zr_salesordertp IN LOCAL MODE
        ENTITY salesorderitem BY \_scheduleline
          FIELDS ( salesorderscheduleline )
            WITH CORRESPONDING #( entities )
            RESULT DATA(lt_sales_order_schedule_lines)
          FAILED failed.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_sales_order_item>).
      " get highest item from sales order items of a sales order
      DATA(max_schedule_line_id) =
      REDUCE #( INIT max = CONV zetenr( '0000' )
             FOR sales_order_schedule_line IN lt_sales_order_schedule_lines
               USING KEY entity WHERE ( salesorder = <ls_sales_order_item>-salesorder
               AND salesorderitem = <ls_sales_order_item>-salesorderitem )
               NEXT max = COND zposnr_ic( WHEN sales_order_schedule_line-salesorderscheduleline > max
               THEN sales_order_schedule_line-salesorderscheduleline
               ELSE max ) )
               .

      "assign sales order schedule line id
      LOOP AT <ls_sales_order_item>-%target ASSIGNING FIELD-SYMBOL(<ls_sales_order_schedule_line>).
        APPEND CORRESPONDING #( <ls_sales_order_schedule_line> ) TO mapped-salesorderscheduleline
    ASSIGNING FIELD-SYMBOL(<ls_mapped_sales_order_sline>).
        IF <ls_sales_order_schedule_line>-salesorderscheduleline IS INITIAL.
          max_schedule_line_id += 1.
          <ls_mapped_sales_order_sline>-salesorderscheduleline = max_schedule_line_id.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD copy.
    READ ENTITY IN LOCAL MODE zr_salesorderitemtp
    ALL FIELDS
    WITH CORRESPONDING #( ls_keys )
    RESULT DATA(salesorderitems)
    FAILED failed.

    DATA create TYPE TABLE FOR CREATE zr_salesordertp\\salesorder\_item.

    LOOP AT ls_keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      READ TABLE salesorderitems ASSIGNING FIELD-SYMBOL(<ls_salesorderitem>)
      WITH KEY id COMPONENTS %tky = <ls_key>-%tky.
      CHECK sy-subrc = 0.
      READ TABLE create ASSIGNING FIELD-SYMBOL(<ls_create>)
      WITH KEY cid COMPONENTS %cid_ref = <ls_key>-%cid_ref
      salesorder = <ls_key>-salesorder.
      IF sy-subrc <> 0.
        APPEND VALUE #( %cid_ref = <ls_key>-%cid_ref
                      salesorder = <ls_key>-salesorder ) TO create ASSIGNING <ls_create>.
      ENDIF.
      DO <ls_key>-%param-numberofcopies TIMES.
        APPEND VALUE #( product = <ls_salesorderitem>-product
                        orderquantity = <ls_salesorderitem>-orderquantity
                        orderquantityunit = <ls_salesorderitem>-orderquantityunit
                        netamount = <ls_salesorderitem>-netamount
                        transactioncurrency = <ls_salesorderitem>-transactioncurrency
                        ) TO <ls_create>-%target.
      ENDDO.
      MODIFY ENTITY IN LOCAL MODE zr_salesordertp
      CREATE BY \_item
      FIELDS (  product orderquantity orderquantityunit netamount transactioncurrency )
      AUTO FILL CID WITH create
      MAPPED DATA(mapped_local)
      FAILED failed
      REPORTED reported.
      READ ENTITY IN LOCAL MODE zr_salesorderitemtp
      FROM CORRESPONDING #( mapped_local-salesorderitem )
      RESULT DATA(new_salesorderitems).
      LOOP AT new_salesorderitems ASSIGNING
      FIELD-SYMBOL(<ls_new_salesorderitem>).
        APPEND VALUE #( %cid_ref = <ls_key>-%cid_ref
                        %tky = <ls_key>-%tky
                        %param = CORRESPONDING #( <ls_new_salesorderitem> ) ) TO result.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  "  METHOD calculatenetamount.
  "
  "    "please note that for the sake of simplicity in this example
  "    "we assume to have only one transaction currency, e.g. USD
  "    READ ENTITY IN LOCAL MODE ZR_salesorderItemTP
  "      FIELDS ( OrderQuantity Product )
  "      WITH CORRESPONDING #( ls_keys )
  "      RESULT DATA(salesorderitems).
  "
  "    SELECT product, price, currency FROM zi_product WITH PRIVILEGED ACCESS
  "      FOR ALL ENTRIES IN @salesorderitems
  "      WHERE product = @salesorderitems-Product
  "      INTO TABLE @DATA(products).
  "
  "    DATA updates TYPE TABLE FOR UPDATE ZR_salesorderItemTP.
  "
  "    LOOP AT salesorderitems ASSIGNING FIELD-SYMBOL(<salesorderitem>).
  "      READ TABLE products ASSIGNING FIELD-SYMBOL(<product>)
  "        WITH KEY Product = <salesorderitem>-Product.
  "      CHECK sy-subrc = 0.
  "      APPEND VALUE #( %tky                         = <salesorderitem>-%tky
  "                      NetAmount                    = <salesorderitem>-OrderQuantity * <product>-Price
  ""                      "transactioncurrency          = <product>-Currency
  "                      "%control-NetAmount           = if_abap_behv=>mk-on
  "                      "%control-transactioncurrency = if_abap_behv=>mk-on
  "                      )
  "        TO updates.
  "    ENDLOOP.
  "
  "    MODIFY ENTITY IN LOCAL MODE ZR_salesorderItemTP
  "      UPDATE FIELDS ( NetAmount transactioncurrency ) WITH updates.
  "  ENDMETHOD.

  METHOD calculatetotalamount.

    "please note that for the sake of simplicity in this example
    "we assume to have only one transaction currency, e.g. USD
    READ ENTITY IN LOCAL MODE zr_salesorderitemtp
      FIELDS ( orderquantity product )
      WITH CORRESPONDING #( ls_keys )
      RESULT DATA(salesorderitems).


    DATA lt_updates TYPE TABLE FOR UPDATE zr_salesorderitemtp.

    SELECT product, price, currency FROM zi_product WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @salesorderitems
      WHERE product = @salesorderitems-product
      ORDER BY PRIMARY KEY
      INTO TABLE @DATA(lt_products).

    IF sy-subrc = 0.

      LOOP AT salesorderitems ASSIGNING FIELD-SYMBOL(<salesorderitem>).
        READ TABLE lt_products ASSIGNING FIELD-SYMBOL(<ls_product>)
          WITH KEY product = <salesorderitem>-product.
        CHECK sy-subrc = 0.
        APPEND VALUE #( %tky                         = <salesorderitem>-%tky
                        netamount                    = <salesorderitem>-orderquantity * <ls_product>-price
                        transactioncurrency          = <ls_product>-currency
                        %control-netamount           = if_abap_behv=>mk-on
                        %control-transactioncurrency = if_abap_behv=>mk-on

                        )
          TO lt_updates.
      ENDLOOP.

      MODIFY ENTITY IN LOCAL MODE zr_salesorderitemtp
        UPDATE FROM lt_updates.
    ENDIF.
  ENDMETHOD.

  METHOD verifyproduct.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITY IN LOCAL MODE zr_salesorderitemtp BY \_salesorder
     FIELDS ( deliverystatus )
     WITH CORRESPONDING #( ls_keys )
     RESULT DATA(salesorderitems)
     FAILED failed.
    "TODO find out what these ls_keys could mean
    IF sy-subrc = 0.
      LOOP AT ls_keys ASSIGNING FIELD-SYMBOL(<ls_key>).
        READ TABLE salesorderitems ASSIGNING FIELD-SYMBOL(<salesorderitem>)
        WITH KEY id COMPONENTS %tky = <ls_key>-%tky.
        IF <salesorderitem>-deliverystatus = 'C'.
          APPEND VALUE #( %tky = <salesorderitem>-%tky
                            %features = CORRESPONDING #( requested_features ) ) TO result.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
