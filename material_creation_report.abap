REPORT Z_MATERIAL_CREATION.

" Selection Screen
PARAMETERS: p_matnr TYPE matnr OBLIGATORY, " Material Number
            p_mtart TYPE mtart OBLIGATORY, " Material Type
            p_mbrsh TYPE mbrsh, " Industry Sector
            p_meins TYPE meins, " Base Unit of Measure
            p_werks TYPE werks_d. " Plant

" Internal Tables and Work Areas
DATA: lt_messages TYPE TABLE OF bapiret2, " Messages
      ls_headdata TYPE bapimathead,              " Header Data for BAPI
      ls_return TYPE bapiret2.                   " Return Structure

" Start-of-Selection
START-OF-SELECTION.
  " Validate Inputs
  PERFORM validate_inputs.

  " Create Material
  PERFORM create_material.

  " Display Logs
  PERFORM display_logs.

" Form Routines
FORM validate_inputs.
  " Validate material type
  IF p_mtart IS INITIAL.
    WRITE: / 'Material type is required.'.
    EXIT.
  ENDIF.

  " Validate plant
  IF p_werks IS INITIAL.
    WRITE: / 'Plant is required.'.
    EXIT.
  ENDIF.
ENDFORM.

FORM create_material.
  " Populate header data for BAPI
  CLEAR ls_headdata.
  ls_headdata-material = p_matnr.
  ls_headdata-matl_type = p_mtart.
  ls_headdata-ind_sector = p_mbrsh.
  ls_headdata-base_uom = p_meins.
  ls_headdata-plant = p_werks.

  " Call BAPI to create material
  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      headdata = ls_headdata
    IMPORTING
      return = ls_return
    TABLES
      returnmessages = lt_messages.

  " Check return status
  IF ls_return-type = 'E'.
    WRITE: / 'Error creating material:', ls_return-message.
    EXIT.
  ENDIF.
ENDFORM.

FORM display_logs.
  " Display messages
  LOOP AT lt_messages INTO DATA(ls_message).
    WRITE: / ls_message-message.
  ENDLOOP.
ENDFORM.
