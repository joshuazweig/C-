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
        [stmt_list:]
        [stmt:
          IF
          LPAREN
          [expr: [expr: LITERAL] GT [expr: LITERAL]]
          RPAREN
          [stmt:
            LBRACE
            [stmt_list:
              [stmt_list:]
              [stmt: [expr: ID ASSIGN [expr: LITERAL]] SEMI]
            ]
            RBRACE
          ]
          ELSE
          [stmt:
            LBRACE
            [stmt_list:
              [stmt_list:]
              [stmt: [expr: ID ASSIGN [expr: LITERAL]] SEMI]
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
