function(rift_json_to_list JSON_ARRAY OUTPUT_LIST)
    string(REPLACE "[" "" JSON_ARRAY "${JSON_ARRAY}")
    string(REPLACE "]" "" JSON_ARRAY "${JSON_ARRAY}")
    string(REPLACE "\n" "" JSON_ARRAY "${JSON_ARRAY}")
    string(REPLACE "\"" "" JSON_ARRAY "${JSON_ARRAY}")

    separate_arguments(OUT_LIST UNIX_COMMAND "${JSON_ARRAY}")

    string(REPLACE "," "" OUT_LIST "${OUT_LIST}")

    set(${OUTPUT_LIST} ${OUT_LIST} PARENT_SCOPE)
endfunction()