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
      [vdecl_list:
        [vdecl_list:
          [vdecl_list: [vdecl_list:] [vdecl: [typ: STONE] ID SEMI]]
          [vdecl: [typ: STONE] ID SEMI]
        ]
        [vdecl: [typ: MINT] ID SEMI]
      ]
      [stmt_list:
        [stmt_list:]
        [stmt:
          [expr: ID ASSIGN [expr: LT [expr: ID] COMMA [expr: ID] GT]]
          SEMI
        ]
      ]
      RBRACE
    ]
  ]
  EOF
]
