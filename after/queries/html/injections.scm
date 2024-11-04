;; extends

(element
  (_ (tag_name) @_tag
      (#lua-match? @_tag "^twig:%a")
  (attribute
    (attribute_name) @_attr
      (#lua-match? @_attr "^:%a")
    (quoted_attribute_value
      (attribute_value) @injection.content)
        (#set! injection.language "javascript")
    )))
