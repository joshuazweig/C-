; ModuleID = 'Cmod'

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt2 = private unnamed_addr constant [3 x i8] c"%s\00"
@fmts = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmts.1 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmts.2 = private unnamed_addr constant [4 x i8] c"%d\0A\00"

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
  %x = alloca i32
  store i32 1, i32* %x
  %y = alloca i32
  store i32 3, i32* %y
  %z = alloca i32
  store i32 3, i32* %z
  %z1 = load i32, i32* %z
  %y2 = load i32, i32* %y
  %tmp = mul i32 %z1, %y2
  %x3 = load i32, i32* %x
  %tmp4 = add i32 %tmp, %x3
  %0 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmts, i32 0, i32 0), i32 %tmp4)
  store i32 4, i32* %y
  %y5 = load i32, i32* %y
  %1 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmts.1, i32 0, i32 0), i32 %y5)
  store i32 5, i32* %x
  %x6 = load i32, i32* %x
  %2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmts.2, i32 0, i32 0), i32 %x6)
  ret i32 0
}
