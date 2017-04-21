; ModuleID = 'Cmod'

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt2 = private unnamed_addr constant [3 x i8] c"%s\00"
@fmts = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare i32 @printf(i8*, ...)

declare i32 @scanf(i8*, i8*)

declare i8* @malloc(i32)

declare { i8*, i8* } @mint_add_func({ i8*, i8* }*, { i8*, i8* }*)

declare { i8*, i8* } @mint_sub_func({ i8*, i8* }*, { i8*, i8* }*)

declare { i8*, i8* } @mint_mult_func({ i8*, i8* }*, { i8*, i8* }*)

declare { i8*, i8* } @mint_pow_func({ i8*, i8* }*, { i8*, i8* }*)

declare { i8*, i8* } @mint_to_stone_func({ i8*, i8* }*, i8*)

declare i8* @stone_char_func(i8*, i8*)

declare i8* @stone_add_func(i8*, i8*)

declare i8* @stone_sub_func(i8*, i8*)

declare i8* @stone_mult_func(i8*, i8*)

declare i8* @stone_div_func(i8*, i8*)

declare i8* @stone_pow_func(i8*, i8*)

declare i8* @stone_mod_func(i8*, i8*)

declare i32 @stone_print_func(i8*)

declare i32 @mint_print_func({ i8*, i8* })

declare i8* @point_add_func(i8*, i8*)

declare i8* @point_sub_func(i8*, i8*)

declare i8* @point_mult_func(i8*, i8*)

declare i8* @stone_create_func(i8*)

define i32 @main() {
entry:
  %i = alloca i32
  store i32 0, i32* %i
  br label %while

while:                                            ; preds = %while_body, %entry
  %i5 = load i32, i32* %i
  %tmp6 = icmp slt i32 %i5, 5
  br i1 %tmp6, label %while_body, label %merge

while_body:                                       ; preds = %while
  %x = alloca i32
  %i1 = load i32, i32* %i
  %tmp = mul i32 3, %i1
  store i32 %tmp, i32* %x
  %x2 = load i32, i32* %x
  %0 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmts, i32 0, i32 0), i32 %x2)
  %i3 = load i32, i32* %i
  %tmp4 = add i32 %i3, 1
  store i32 %tmp4, i32* %i
  br label %while

merge:                                            ; preds = %while
  store i32 10, i32* %i
  %i7 = load i32, i32* %i
  ret i32 %i7
}
