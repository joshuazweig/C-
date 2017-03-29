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
          WHILE
          LPAREN
          [expr: LITERAL]
          RPAREN
          [stmt:
            LBRACE
            [stmt_list:
              [stmt_list:
                [stmt_list:
                  [stmt_list:]
                  [stmt:
                    IF
                    LPAREN
                    [expr: ID ASSIGN [expr: LITERAL]]
                    RPAREN
                    [stmt:
                      LBRACE
                      [stmt_list:
                        [stmt_list:
                          [stmt_list:]
                          [stmt: [expr: ID ASSIGN [expr: LITERAL]] SEMI]
                        ]
                        [stmt: CONTINUE SEMI]
                      ]
                      RBRACE
                    ]
                  ]
                ]
                [stmt:
                  [expr: ID ASSIGN [expr: [expr: ID] PLUS [expr: LITERAL]]]
                  SEMI
                ]
              ]
              [stmt:
                IF
                LPAREN
                [expr: ID ASSIGN [expr: LITERAL]]
                RPAREN
                [stmt:
                  LBRACE
                  [stmt_list:
                    [stmt_list:
                      [stmt_list:]
                      [stmt:
                        [expr: ID ASSIGN [expr: [expr: ID] STAR [expr: LITERAL]]]
                        SEMI
                      ]
                    ]
                    [stmt: BREAK SEMI]
                  ]
                  RBRACE
                ]
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
