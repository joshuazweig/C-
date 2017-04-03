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
              [expr:
                LPAREN
                [expr:
                  [expr: LITERAL]
                  EQ
                  [expr: [expr: LITERAL] LT [expr: LITERAL]]
                ]
                RPAREN
              ]
            ]
            SEMI
          ]
        ]
        [stmt:
          [expr:
            ID
            ASSIGN
            [expr:
              LPAREN
              [expr:
                [expr: [expr: LITERAL] LEQ [expr: LITERAL]]
                NEQ
                [expr: LITERAL]
              ]
              RPAREN
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
