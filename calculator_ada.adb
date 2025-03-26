with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings; use Ada.Strings;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;

procedure Calculator_Ada is
   type Token_Type is (Number, Plus, Minus, Multiply, Divide, Left_Paren, Right_Paren);
   
   type Token is record
      Kind : Token_Type;
      Value : Float := 0.0;
   end record;
   
   type Token_Array is array (Positive range <>) of Token;
   
   
   function Tokenize (Expr : String) return Token_Array is
      Tokens : Token_Array(1..Expr'Length);
      Token_Count : Natural := 0;
      I : Positive := Expr'First;
   begin
      while I <= Expr'Last loop
         
         while I <= Expr'Last and then Expr(I) = ' ' loop
            I := I + 1;
         end loop;
         
         exit when I > Expr'Last;
         
         case Expr(I) is
            when '+' => 
               Token_Count := Token_Count + 1;
               Tokens(Token_Count) := (Kind => Plus, Value => 0.0);
               I := I + 1;
            when '-' => 
               Token_Count := Token_Count + 1;
               Tokens(Token_Count) := (Kind => Minus, Value => 0.0);
               I := I + 1;
            when '*' => 
               Token_Count := Token_Count + 1;
               Tokens(Token_Count) := (Kind => Multiply, Value => 0.0);
               I := I + 1;
            when '/' => 
               Token_Count := Token_Count + 1;
               Tokens(Token_Count) := (Kind => Divide, Value => 0.0);
               I := I + 1;
            when '(' => 
               Token_Count := Token_Count + 1;
               Tokens(Token_Count) := (Kind => Left_Paren, Value => 0.0);
               I := I + 1;
            when ')' => 
               Token_Count := Token_Count + 1;
               Tokens(Token_Count) := (Kind => Right_Paren, Value => 0.0);
               I := I + 1;
            when '0'..'9' =>
               declare
                  Start : constant Positive := I;
               begin
                  while I <= Expr'Last and then (Expr(I) in '0'..'9' or Expr(I) = '.') loop
                     I := I + 1;
                  end loop;
                  Token_Count := Token_Count + 1;
                  Tokens(Token_Count) := (
                     Kind => Number, 
                     Value => Float'Value(Expr(Start..I-1))
                  );
               end;
            when others => 
               raise Constraint_Error;
         end case;
      end loop;
      
      return Tokens(1..Token_Count);
   end Tokenize;
   
   
   function Evaluate (Tokens : Token_Array) return Float is
      Result_Stack : array (1..100) of Float;
      Operator_Stack : array (1..100) of Token_Type;
      Result_Top : Natural := 0;
      Operator_Top : Natural := 0;
      
      procedure Push_Result (Value : Float) is
      begin
         Result_Top := Result_Top + 1;
         Result_Stack(Result_Top) := Value;
      end Push_Result;
      
      procedure Push_Operator (Op : Token_Type) is
      begin
         Operator_Top := Operator_Top + 1;
         Operator_Stack(Operator_Top) := Op;
      end Push_Operator;
      
      function Precedence (Op : Token_Type) return Integer is
      begin
         case Op is
            when Multiply | Divide => return 2;
            when Plus | Minus => return 1;
            when others => return 0;
         end case;
      end Precedence;
      
      procedure Apply_Operator is
         Right, Left : Float;
         Op : Token_Type;
      begin
         Right := Result_Stack(Result_Top);
         Result_Top := Result_Top - 1;
         Left := Result_Stack(Result_Top);
         Result_Top := Result_Top - 1;
         Op := Operator_Stack(Operator_Top);
         Operator_Top := Operator_Top - 1;
         
         case Op is
            when Plus => Push_Result(Left + Right);
            when Minus => Push_Result(Left - Right);
            when Multiply => Push_Result(Left * Right);
            when Divide => 
               if Right /= 0.0 then
                  Push_Result(Left / Right);
               else
                  raise Constraint_Error;
               end if;
            when others => 
               raise Constraint_Error;
         end case;
      end Apply_Operator;
   begin
      for I in Tokens'Range loop
         case Tokens(I).Kind is
            when Number => 
               Push_Result(Tokens(I).Value);
            
            when Left_Paren => 
               Push_Operator(Left_Paren);
            
            when Right_Paren => 
               while Operator_Top > 0 and then Operator_Stack(Operator_Top) /= Left_Paren loop
                  Apply_Operator;
               end loop;
               
               if Operator_Top > 0 and then Operator_Stack(Operator_Top) = Left_Paren then
                  Operator_Top := Operator_Top - 1;
               else
                  raise Constraint_Error;
               end if;
            
            when Plus | Minus | Multiply | Divide => 
               while Operator_Top > 0 and then 
                     Precedence(Operator_Stack(Operator_Top)) >= Precedence(Tokens(I).Kind) and then
                     Operator_Stack(Operator_Top) /= Left_Paren loop
                  Apply_Operator;
               end loop;
               Push_Operator(Tokens(I).Kind);
         end case;
      end loop;
      
      while Operator_Top > 0 loop
         if Operator_Stack(Operator_Top) = Left_Paren then
            raise Constraint_Error;
         end if;
         Apply_Operator;
      end loop;
      
      return Result_Stack(1);
   end Evaluate;
   
   procedure Calculator_Loop is
      Expr : Unbounded_String;
   begin
      loop
         Put("> ");
         declare
            Input : String := Get_Line;
            Tokens : Token_Array := Tokenize(Input);
         begin
            if Input = "quit" then
               Put_Line("Exiting calculator.");
               exit;
            end if;
            
            Put("Result: "); Put(Evaluate(Tokens), 0, 6, 0); New_Line;
         exception
            when Constraint_Error => 
               Put_Line("Error: Invalid expression");
         end;
      end loop;
   end Calculator_Loop;
begin
   Put_Line("Simple Ada Calculator");
   Put_Line("Enter expressions. Type 'quit' to exit.");
   Calculator_Loop;
end Calculator_Ada;