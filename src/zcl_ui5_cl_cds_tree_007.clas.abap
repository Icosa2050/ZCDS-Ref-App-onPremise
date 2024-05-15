CLASS zcl_ui5_cl_cds_tree_007 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES: BEGIN OF ts_tree_row_base,
             employee              TYPE numc4,
             node_text             TYPE string,
             node_id               TYPE numc4,
             parent_id             TYPE numc4,
             hierarchy_level       TYPE numc4,
             hierarchy_tree_size   TYPE numc4,
             hierarchy_rank        TYPE numc4,
             hierarchy_parent_rank TYPE numc4,
             hierarchy_is_orphan   TYPE numc1,
             hierarchy_is_cycle    TYPE numc1,
           END OF ts_tree_row_base.

    TYPES BEGIN OF ts_tree_level3.
    INCLUDE TYPE ts_tree_row_base.
    TYPES END OF ts_tree_level3.

    TYPES tt_tree_level3 TYPE STANDARD TABLE OF ts_tree_level3 WITH KEY node_id.

    TYPES BEGIN OF ts_tree_level2.
    INCLUDE TYPE ts_tree_row_base.
    TYPES   employees TYPE tt_tree_level3.
    TYPES END OF ts_tree_level2.

    TYPES tt_tree_level2 TYPE STANDARD TABLE OF ts_tree_level2 WITH KEY node_id.

    TYPES BEGIN OF ts_tree_level1.
    INCLUDE TYPE ts_tree_row_base.
    TYPES   employees TYPE tt_tree_level2.
    TYPES END OF ts_tree_level1.

    TYPES tt_tree_level1 TYPE STANDARD TABLE OF ts_tree_level1 WITH KEY node_id.

    DATA mt_tree TYPE tt_tree_level1.
    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ui5_cl_cds_tree_007 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.
    DATA ls_tree1 TYPE ts_tree_level1.
    DATA ls_tree2 TYPE ts_tree_level2.
    DATA ls_tree3 TYPE ts_tree_level3.
    DATA: lv_tree_text TYPE lvc_value.


    IF check_initialized = abap_false.
      check_initialized = abap_true.
      SELECT
     FROM zhi_hierarchicalemployee03
     FIELDS
       employee,
       \_employee-employeename AS node_text,
       node_id,
       parent_id,
       hierarchy_level,
       hierarchy_tree_size,
       hierarchy_rank,
       hierarchy_parent_rank,
       hierarchy_is_orphan,
       hierarchy_is_cycle
     ORDER BY hierarchy_rank
     INTO TABLE @DATA(gt_hierarchy_display).

      LOOP AT gt_hierarchy_display ASSIGNING FIELD-SYMBOL(<ls_node_data>).
        IF <ls_node_data>-hierarchy_level = 1.
        ls_tree1 = CORRESPONDING #( <ls_node_data> ).
          "MOVE-CORRESPONDING <ls_node_data> TO ls_tree1.
          APPEND ls_tree1 TO mt_tree.
        ELSE.
          READ TABLE gt_hierarchy_display WITH KEY parent_id = <ls_node_data>-parent_id
                                      ASSIGNING FIELD-SYMBOL(<ls_parent_data>).
          lv_tree_text = <ls_node_data>-node_text.

          IF sy-subrc = 0.
            READ TABLE mt_tree WITH KEY node_id = <ls_node_data>-parent_id
                                        ASSIGNING FIELD-SYMBOL(<ls_parent>).
            IF sy-subrc = 0.
            ls_tree2 = CORRESPONDING #( <ls_node_data> ).
              "MOVE-CORRESPONDING <ls_node_data> TO ls_tree2.
              APPEND  ls_tree2 TO <ls_parent>-employees.
            ELSE.
              APPEND INITIAL LINE TO mt_tree ASSIGNING FIELD-SYMBOL(<new_node>).
              <new_node> = CORRESPONDING #( <ls_parent_data> ).
              "MOVE-CORRESPONDING <ls_node_data> TO <new_node>.

            ENDIF.
          ENDIF.

        ENDIF.

      ENDLOOP.

      "      mt_tree = VALUE #( ( object = '1' categories = VALUE #( ( object = '1.1' categories = VALUE #( ( object = '1.1.1')
      "                                                                                                     ( object = '1.1.2') ) )
      "                                                                               ( object = '1.2' ) ) )
      "                         ( object = '2' categories = VALUE #( ( object = '2.1' )
      "                                                              ( object = '2.2' ) ) )
      "                         ( object = '3' categories = VALUE #( ( object = '3.1' )
      "                                                              ( object = '3.2' ) ) ) ).
    ENDIF.

    CASE client->get( )-event.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
    ENDCASE.

    DATA(view) = z2ui5_cl_xml_view=>factory( ).
    DATA(page) = view->shell(
        )->page(
            title          = 'abap2UI5 - TreeTable'
            navbuttonpress = client->_event( 'BACK' )
              shownavbutton = abap_true
            )->header_content(
               )->link( text = 'My Tree'        target = '_blank' href = `https://twitter.com/abap2UI5/status/1673320288983842820`
               )->link(


            )->get_parent( ).

    DATA(tab) = page->tree_table(
      rows = `{path:'` && client->_bind( val = mt_tree path = abap_true ) && `', parameters: {arrayNames:['EMPLOYEES']}}` ).
    tab->tree_columns(
    )->tree_column( label = 'Employee'
        )->tree_template(
        )->text( text = '{EMPLOYEE}')->get_parent( )->get_parent(

        )->tree_column( label = 'NODE_TEXT'
        )->tree_template(
        )->text( text = '{NODE_TEXT}')->get_parent( )->get_parent(

        )->tree_column( label = 'NODE_ID'
        )->tree_template(
        )->text( text = '{NODE_ID}')->get_parent( )->get_parent(

        )->tree_column( label = 'PARENT_ID'
        )->tree_template(
        )->text( text = '{PARENT_ID}').

    client->view_display( view->stringify( ) ).

  ENDMETHOD.
ENDCLASS.
