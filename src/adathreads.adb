with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;

procedure Adathreads is
   can_stop : Boolean := False;
   pragma Atomic (can_stop);

   task type Worker_Thread (Id : Integer; Step : Integer) is
      entry Start;
   end Worker_Thread;

   task body Worker_Thread is
      Sum : Long_Long_Integer := 0;
      Count : Long_Long_Integer := 0;
   begin
      accept Start;
      for I in 0 .. Integer'Last loop
         exit when can_stop;
         Sum := Sum + Long_Long_Integer(Step);
         Count := Count + 1;
      end loop;
      Put_Line ("Thread" & Id'Img & ": Sum =" & Sum'Img & ", Elements Count =" & Count'Img);
   end Worker_Thread;

   task type Break_Thread is
      entry Start;
   end Break_Thread;

   task body Break_Thread is
   begin
      accept Start;
      delay 5.0;
      can_stop := True;
   end Break_Thread;

   B : Break_Thread;
   subtype Random_Range is Integer range 1 .. 10;
   package Random_Int is new Ada.Numerics.Discrete_Random(Random_Range);
   use Random_Int;
   G : Generator;

   type Worker_Access is access Worker_Thread;
   type Worker_Array is array (1 .. 4) of Worker_Access;
   Tasks : Worker_Array;

begin
   Reset(G);
   for I in Tasks'Range loop
      Tasks(I) := new Worker_Thread(I, Random(G));
      Tasks(I).Start;
   end loop;

   B.Start;
end Adathreads;
