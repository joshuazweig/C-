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
          DO
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
          WHILE
          LPAREN
          [expr: [expr: ID] LT [expr: LITERAL]]
          RPAREN
        ]
      ]
      RBRACE
    ]
  ]
  EOF
]
