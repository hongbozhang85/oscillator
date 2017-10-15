--
-- Uwe R. Zimmer, Australia 2015
--

with Ada.Real_Time;                 use Ada.Real_Time;
with ANU_Base_Board.LED_Interface;  use ANU_Base_Board.LED_Interface;
with Discovery_Board.LED_Interface; use Discovery_Board.LED_Interface;
-- with Wave;                          pragma Unreferenced (Wave);
-- with Receive_Wave;                  pragma Unreferenced (Receive_Wave);
-- with Receive_Wave_One;              pragma Unreferenced (Receive_Wave_One);
-- with Wave_Single_Board_Test;        pragma Unreferenced (Wave_Single_Board_Test);
-- with Gen_Rec_In_One;                use Gen_Rec_In_One;

with System; use System;

procedure Oscillator with Priority => Priority'First is

   System_Startup : constant Time      := Clock;
   Reset_Flicker  : constant Time_Span := Milliseconds (100);

   package ABBL renames ANU_Base_Board.LED_Interface;
   package DBL  renames Discovery_Board.LED_Interface;

   -----spawn task------
   -- testWave : SquareWave;
   -- receiver4 : Receiver;

begin

   -- All tasks are running at this point.

   -- Briefly flickering all lights to acknowledge a successful start.

   DBL.All_On;
   ABBL.All_On;
   delay until System_Startup + Reset_Flicker;
   DBL.All_Off;
   ABBL.All_Off;

   loop
      null; -- Main task (at lowest priority) needs to be prevented from exiting
   end loop;
end Oscillator;
