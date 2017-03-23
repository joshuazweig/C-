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
          [stmt:
            [expr:
              ID
              ASSIGN
              [expr: [expr: MINUS [expr: LITERAL]] STAR [expr: LITERAL]]
            ]
            SEMI
          ]
        ]
        [stmt: [expr: ID ASSIGN [expr: MINUS [expr: ID]]] SEMI]
      ]
      RBRACE
    ]
  ]
  EOF
]
