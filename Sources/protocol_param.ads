with STM32F4;                                     use STM32F4;

package Protocol_Param is
   
   -- Tx_Freq: transmitter send wave signal to COM_PORTS every T/Tx_Freq, T ~ 1s/50
   -- Rx_Freq: receiver sample input data at COM_PORTS every T/Rx_Freq
   Tx_Freq : constant Positive := 1024; 
   Rx_Freq : constant Positive := 512;
   
   -- Wave_Value is the value of wave signal. 
   -- it ranges from 0 to 1024, so it requires 10 bit to store this value.
   subtype Wave_Value is Bits_10 range 0 .. 1023;
   
   -- the data type communicate between COM_PORTS
   type Wave_Encode is record
      Wave : Wave_Value;
      Reserved : Bits_22;
   end Wave_Value with Volatile, Size => Word'Size;
   
private
   
   for Wave_Encode use record
      Reserved at 0 range 10 .. 31;
      Wave at 0 range 0 .. 9;
   end Wave_Encode;

end Protocol_Param;
