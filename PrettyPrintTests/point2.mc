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
        [vdecl_list: [vdecl_list:] [vdecl: [typ: CURVE] ID SEMI]]
        [vdecl: [typ: POINT] ID SEMI]
      ]
      [stmt_list:
        [stmt_list:]
        [stmt:
          [expr: ID ASSIGN [expr: LT [expr: ID] COMMA [expr: INF] GT]]
          SEMI
        ]
      ]
      RBRACE
    ]
  ]
  EOF
]
