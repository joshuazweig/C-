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
          [expr:
            ID
            ASSIGN
            [expr:
              [expr:
                LPAREN
                [expr: [expr: LITERAL] PLUS [expr: LITERAL]]
                RPAREN
              ]
              STAR
              [expr:
                LPAREN
                [expr:
                  [expr: LITERAL]
                  DIVIDE
                  [expr:
                    LPAREN
                    [expr: [expr: LITERAL] MINUS [expr: LITERAL]]
                    RPAREN
                  ]
                ]
                RPAREN
              ]
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
