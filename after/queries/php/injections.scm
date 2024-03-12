; extends

; printf
((function_call_expression
  function: (_) @_printf_func_identifier
  arguments:
    (arguments
      .
      (argument
        (_
          (string_value) @injection.content))))
  (#set! injection.language "printf")
  (#any-of? @_printf_func_identifier
    "fprintf" "printf" "sprintf" "vfprintf" "vprintf" "vsprintf"))
