ACCEPT
[program:
  [decls:
    [decls:]
    [fdecl:
      [typ: INT]
      ID
      LPAREN
      [formals_opt:]
      RPAREN
      LBRACE
      [vdecl_list: [vdecl_list:] [vdecl: [typ: MINT] ID SEMI]]
      [stmt_list:
        [stmt_list:]
        [stmt:
          [expr:
            ID
            ASSIGN
            [expr:
              LT
              [expr: [expr: LITERAL] OR [expr: LITERAL]]
              COMMA
              [expr: [expr: LITERAL] POW [expr: LITERAL]]
              GT
            ]
          ]
          SEMI
        ]
      ]
      RBRACE
    ]
  ]
  EOF
]
