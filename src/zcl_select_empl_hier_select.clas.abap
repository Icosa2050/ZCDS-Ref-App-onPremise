CLASS zcl_select_empl_hier_select DEFINITION PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_select_empl_hier_select IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


    SELECT
      FROM ZHI_HierarchicalEmployee03
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
      INTO TABLE @DATA(gt_hier).

    out->write( gt_hier ).

  ENDMETHOD.
ENDCLASS.
