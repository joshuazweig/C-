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
        [vdecl_list: [vdecl_list:] [vdecl: [typ: INT] ID SEMI]]
        [vdecl: [typ: INT] ID SEMI]
      ]
      [stmt_list:
        [stmt_list:
          [stmt_list:]
          [stmt: [expr: ID ASSIGN [expr: LITERAL]] SEMI]
        ]
        [stmt:
          FOR
          LPAREN
          [expr_opt: [expr: ID ASSIGN [expr: LITERAL]]]
          SEMI
          [expr_opt: [expr: [expr: ID] LT [expr: LITERAL]]]
          SEMI
          [expr_opt:
            [expr: ID ASSIGN [expr: [expr: ID] PLUS [expr: LITERAL]]]
          ]
          RPAREN
          [stmt:
            LBRACE
            [stmt_list:
              [stmt_list:]
              [stmt:
                [expr: ID ASSIGN [expr: [expr: ID] PLUS [expr: LITERAL]]]
                SEMI
              ]
            ]
            RBRACE
          ]
        ]
      ]
      RBRACE
    ]
  ]
  EOF
]
