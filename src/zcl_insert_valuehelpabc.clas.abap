CLASS zcl_insert_valuehelpabc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    DATA : out TYPE REF TO if_oo_adt_classrun_out.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_insert_valuehelpabc IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
*####################################################################

    me->out = out.
*####################################################################

    DATA: ls_a TYPE zvaluehelpa.
    DATA: lt_a TYPE STANDARD TABLE OF zvaluehelpa WITH EMPTY KEY.

    DATA: ls_b TYPE zvaluehelpb.
    DATA: lt_b TYPE STANDARD TABLE OF zvaluehelpb WITH EMPTY KEY.

    DATA: ls_c TYPE zvaluehelpc.
    DATA: lt_c TYPE STANDARD TABLE OF zvaluehelpc WITH EMPTY KEY.

    SELECT * FROM  zvaluehelpa INTO TABLE @lt_a.
    IF sy-subrc = 0.
      DELETE zvaluehelpa FROM TABLE @lt_a.
      COMMIT WORK.
    ENDIF.

    CLEAR lt_a.
    CLEAR ls_a.

    ls_a-fielda1        = 'A1_1'.
    ls_a-fielda2        = 'B1_1'.

    INSERT ls_a INTO TABLE lt_a.

    CLEAR ls_a.
    ls_a-fielda1        = 'A1_2'.
    ls_a-fielda2        = 'B1_2'.

    INSERT ls_a INTO TABLE lt_a.
    CLEAR ls_a.

    ls_a-fielda1        = 'A1_3'.
    ls_a-fielda2        = 'B1_3'.

    INSERT ls_a INTO TABLE lt_a.


    INSERT zvaluehelpa FROM TABLE @lt_a.
    IF sy-subrc <> 0.
      out->write( 'Data modification failed' ).
    ELSE.
      "  INSERT zhp_employee FROM TABLE @lt_zhp_employee.
      out->write(  'Data modification was successfully' ).
      COMMIT WORK.
      CLEAR lt_a.
      SELECT * FROM zvaluehelpa INTO TABLE @lt_a.
      out->write(  lt_a ).
    ENDIF.

    SELECT * FROM  zvaluehelpb INTO TABLE @lt_b.
    IF sy-subrc = 0.
      DELETE zvaluehelpb FROM TABLE @lt_b.
      COMMIT WORK.
    ENDIF.
    CLEAR lt_b.

    CLEAR ls_b.

    ls_b-fieldb1        = 'B1_1'.
    ls_b-fieldb2        = 'B2_1'.
    ls_b-fieldb3        = 'B3_1'.

    INSERT ls_b INTO TABLE lt_b.

    CLEAR ls_b.
    ls_b-fieldb1        = 'B1_2'.
    ls_b-fieldb2        = 'B2_2'.
    ls_b-fieldb3        = 'B3_2'.

    INSERT ls_b INTO TABLE lt_b.
    CLEAR ls_b.

    ls_b-fieldb1        = 'B1_3'.
    ls_b-fieldb2        = 'B2_3'.
    ls_b-fieldb3        = 'B3_3'.

    INSERT ls_b INTO TABLE lt_b.


    INSERT zvaluehelpb FROM TABLE @lt_b.

    IF sy-subrc <> 0.
      out->write( 'Data modification failed' ).
      out->write(  ls_b  ).
      EXIT.
    ENDIF.
    "  INSERT zhp_employee FROM TABLE @lt_zhp_employee.
    IF sy-subrc = 0.
      out->write(  'Data modification was successfully' ).
      COMMIT WORK.
      CLEAR lt_b.
      SELECT * FROM zvaluehelpb INTO TABLE @lt_b.
      out->write(  lt_b ).
    ELSE.
      out->write( 'Data modification failed' ).
    ENDIF.


    SELECT * FROM zValueHelpC INTO TABLE @lt_c.
    IF sy-subrc = 0.
      DELETE zValueHelpC  FROM TABLE lt_c.
    ENDIF.
    CLEAR lt_c.
    CLEAR ls_c.
    ls_c-fieldc1        = 'A1_1'.

    INSERT ls_c INTO TABLE lt_c.

    CLEAR ls_c.
    ls_c-fieldc1        = 'A1_4'.

    INSERT ls_c INTO TABLE lt_c.

    INSERT zValueHelpC  FROM TABLE lt_c.
    IF sy-subrc <> 0.
      out->write( 'Data modification failed' ).
    ELSE.
      out->write(  'Data modification was successfully' ).
      CLEAR lt_c.
      SELECT * FROM zvaluehelpc INTO TABLE @lt_c.
      out->write(  lt_c ).
    ENDIF.




  ENDMETHOD.
ENDCLASS.
