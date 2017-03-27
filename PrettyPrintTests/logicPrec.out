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
      [vdecl_list: [vdecl_list:] [vdecl: [typ: INT] ID SEMI]]
      [stmt_list:
        [stmt_list:
          [stmt_list:]
          [stmt: [expr: ID ASSIGN [expr: LITERAL]] SEMI]
        ]
        [stmt:
          [expr:
            ID
            ASSIGN
            [expr:
              [expr:
                LPAREN
                [expr: [expr: LITERAL] AND [expr: NOT [expr: ID]]]
                RPAREN
              ]
              OR
              [expr: LITERAL]
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
