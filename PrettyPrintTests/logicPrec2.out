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
          [stmt_list:
            [stmt_list:
              [stmt_list:]
              [stmt: [expr: ID ASSIGN [expr: LITERAL]] SEMI]
            ]
            [stmt: [expr: ID ASSIGN [expr: LITERAL]] SEMI]
          ]
          [stmt:
            [expr:
              ID
              ASSIGN
              [expr: LPAREN [expr: [expr: ID] GT [expr: ID]] RPAREN]
            ]
            SEMI
          ]
        ]
        [stmt:
          [expr:
            ID
            ASSIGN
            [expr:
              [expr: LITERAL]
              OR
              [expr: [expr: LITERAL] AND [expr: LITERAL]]
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
