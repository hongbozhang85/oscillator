# To Do Next

## Signal Generator 
+ [ ] A task generate a signal
	- [x] square wave **oct-04**
	- [x] sawtooth wave **oct-05**
	- [ ] sine wave
	- [x] all LEDs on D-Board and ANU-Board shows the wave **oct-04**
	- [x] all LEDs, relevant COM-PORTS LED shows the wave **oct-05**
+ [ ] A task generate signals to four COM-PORTS
	- [x] send signals to all four COM-PORTS (TX Data, left LED) **oct-06**
+ [ ] signal generation task for test on a single board
	- [ ] two independant task generate independant signals to two different COM-PORTS (say, 'FIRST and 'LAST) **oct-07**
+ [ ] advanced signal generation task
	- [ ] COM-PORTS Tx Data send data according to protocal

## Signal Receiver
+ [ ] A task receives signals
	- [x] a receiver listens at COM-PORTS'Last. **oct-05**
	- [ ] four receives listen at four COM-PORTS. **oct-06**

## Signal Communication
+ [ ] Build a protocol of communication through COM-PORTS
+ [ ] COM-PORTS'First and COM-PORTS'Last communicate through RJ45.
	- [ ] automatically archieved once a generator and four receivers are both implemented **oct-06, still have bug**
	- [ ] automatically archieved once *signal generator for test on a single board* and four receivers are both implement **oct-07, still have bug**
	- [ ] via protocal

## Synchrony
+ [ ] testing on a single board (there are two COM-PORTS)
	- share memory for each COM-PORTS, store signal from RX Data for a fixed time (e.g., at least the most recent 10 periods). (assuming periods are in range of ?..?)
+ [ ] inter-board synchrony
	- share memory for each board (i.e., four COM-PORTS)
+ [ ] algorithm of calculating period of signals from stored RX Data
+ [ ] algorithm of calculating offset (phase)

## System Control
+ [ ] a scheduler to schedule all tasks actively
+ [ ] a synchroniser to be used in communicate between COM-PORTS

# Problems Met

***Q1 : may be I need scheduling, since when this receiver task run, the wave generator task stops. Met in Oct-05***

**Answer**: I forget to add `delay until` in receiver task, so that this task kept running and there is no time resources left for generator task. Solved in Oct-05

***Q1.1 : While one task is running, and  `delay until` statement of the other task reaches, what happends***
**Answer**:

***Q1.2 : Why can't I instantiate a task in main procedure?***
**Answer**:

***Q2 : violation of implicit restriction "Max_Task_Entries = 0"***
**Answer**: In real time, entry is not allowed. Otherwise, it is required to dispatch in the queue. Implement message passing by COM-PORTS.

***Q3 : Context setting: a sawtoothwave is generated and output to COM-PORTS'First only, four receivers listen at four COM-PORTS. When I wired 'First with 'Third and 'Fourth by RJ45, everything seems OK (R LED of 'First is off, and R LED of 'Third/'Fourth blink in a way as same as L LED of 'First). However, when I wired 'First with 'Second by RJ45, the R LED of 'First is on. Sometimes, even wiring with 'Third and 'Fourth will not work.***
**Suspect**: Four receivers have the same timing requirement, so they may conflict. Try to combine four receivers to a big receiver.
**Experiment**: Combine four receivers into one big receiver. Doesn't solve the problem.

***Q4 : Context setting: a sawtoothwave is generated and output to all four COM-PORTS by `All_Set, All_Reset, All_Left_On, All_Left_Off` method in `wave.adb`, one big receivers listen at four COM-PORTS. But the LED of micro-usb at DB also light up. BTW, the given generator will also enlight micro-usb LED***

# Diary

### Oct04
+ start the project
+ implement a square wave
+ should the square wave by all LEDs on ANUB and DB

### Oct05
+ implement a sawtooth wave
+ a receiver listens at COM-PORTS'First

### Oct06
+ Modified `package Wave` to send signal (SquareWave or SawtoothWave) to all COM-PORTS
+ Four receivers listen at four COM-PORTS
+ *Bugs to be fixed*. Context setting: a sawtoothwave is generated and output to COM-PORTS'First only, four receivers listen at four COM-PORTS. When I wired 'First with 'Third and 'Fourth by RJ45, everything seems OK (R LED of 'First is off, and R LED of 'Third/'Fourth blink in a way as same as L LED of 'First). However, when I wired 'First with 'Second by RJ45, the R LED of 'First is on. Sometimes, even wiring with 'Third and 'Fourth will not work.

### Oct07
+ *Bugs to be fixed*. a sawtoothwave is generated and output to all four COM-PORTS by `All_Set, All_Reset, All_Left_On, All_Left_Off` method in `wave.adb`, one big receivers listen at four COM-PORTS. But the LED of micro-usb at DB also light up.
+ two independant task generate independant signals to two different COM-PORTS (say, 'FIRST and 'LAST), `wave_single_board_test`.
+ *Bugs to be fixed*. 'FIRST cannot receive data.

### Oct10
+ Ben said it might be caused by inapprociate timing. using `delay until` cannot gurantee the LED can be turn on/off at exact time you want, since you don't know what does scheduler do. You `delay until` at timestamp t1, but the LED might turn on at t1 + \delta1. In the same sense, the receiver might receive the signals at t2 + \delta2. So the timing might be broken.
+ So I put squarewave generator and receiver in a whole task. So the system only has two tasks (main task, and SquareWaveGenRec task. Main task has lowest priority, so the system has only one task, essentially. but the system also has bugs.
+ I also change the `Priority` in tasks as well. Bug is still there.
+ My code *should* work, but it doesn't. I didn't find the bug.
+ I will use interrupt, and rewrite the whole project.

### Oct14
+ From reference manual, all pins of `pinx` share the same external interrupt line `EXTIx`. so it is impossible to set general input io register `Port A Pin 2` and `Port C Pin 2` as external interrupts simutaneously.
+ there are 23 interrupt lines `EXTI0 - EXTI22`, only first 16 ones are associated with `GPIO`. other seven are associated with PVD, USB and so on.
+ for each interrupt line
	- interrupt mask register `EXTI_IMR`. `Unmasked` is `1`. unmask extermal interrupt line `EXTIx` before using the xth line. unmask means enable that line.
	- interrupt trigger selection register `EXTI_RTSR EXTI_FTSR`. `1` is triggered at corresponding edge.
	- interrupt pending register, `EXTI_PR`. 
		+ can be used to check whether a selected trigger occurs, or clear the trigger request. it is set when a selected trigger edge comes on external interrupt line.
		+ if it is `1`, then occurs, otherwise, unoccurs. 
		+ it is `rc_w1`, which means read and clear (by writing 1) only. 
		+ when user write this register by `1`, it clear this register to `0` and clear `EXTI_SWIER` to `0` as well.
		+ there are two ways of "occuring an interrupt", one is a real interrupt signal comes, the other is an interrupt generated by software written by programmer (by operating on `EXTI_SWIER` register).
	- interrupt request generation by software, `EXTI_SWIER`. as long as specific interrupt line is enable, writing `1` to this register will generate an interrupt request, and set `EXTI_PR` to `1`.
+ working flow of interrupt
	- set which `Pin` and `Port` in `GPIO` (total 144) associated with which interrupt line `EXTIx` (total 16).
	- set `EXTI_IMR` of corresponding line to make that line enable
	- set `EXTI_RTSR` or `EXTI_FTSR`
	- clear and check the corresponding interrupt by operating on `EXTI_PR`. generate interrupt request by software by operating on `EXTI_SWIER`.
+ attach interrupt handler to specific external interrupt line (EXTI)
	- references: *Reference Manual STM32F4xx* and */usr/local/gnat-arm/arm-eabi/lib/gnat/ravenscar-sfp-stm32f4/gnarl/a-intnam.ads*
	- EXTI0 .. EXTI4 have their own individual interrupt id - EXTI5 .. EXTI9 share one interrupt id
	- EXTI10 .. EXTI15 share one interrupt id
	- find the correct interrupt id, and use `procedure Your_Handler with Attach_Handler => ID`. it is good practice to enscapulate the handler in monitor (protected type).
+ For the COM-PORTS on ANU-BOARD.
	```
	(1 => (Rx => (En => (Port => B, Pin =>  9),
                   Da => (Port => B, Pin =>  7)),
               Tx => (En => (Port => B, Pin =>  8),
                   Da => (Port => B, Pin =>  6))),
         2 => (Rx => (En => (Port => D, Pin =>  1),
                      Da => (Port => D, Pin =>  6)),
               Tx => (En => (Port => D, Pin =>  3),
                      Da => (Port => D, Pin =>  5))),
         3 => (Rx => (En => (Port => C, Pin => 15),
                      Da => (Port => C, Pin => 11)),
               Tx => (En => (Port => C, Pin => 13),
                      Da => (Port => C, Pin => 10))),
         4 => (Rx => (En => (Port => D, Pin =>  7),
                      Da => (Port => D, Pin =>  2)),
               Tx => (En => (Port => B, Pin =>  5),
                      Da => (Port => C, Pin => 12))));
	```
+ the corresponding external interrupt line. So the read interrupt of COM-PORT2 is conflict with the write interrupt of COM-PORT1

	Rx/Tx | COM-PORT | Pin | Port | EXTIx
	--- | --- | --- | --- | ---
	Rx | 1 | 7 | B | EXTI7
	Rx | 2 | 6 | D | EXTI6
	Rx | 3 | 11| C | EXTI11 
	Rx | 4 | 2 | D | EXTI2 
	Tx | 1 | 6 | B | EXTI6 
	Tx | 2 | 5 | D | EXTI5 
	Tx | 3 | 10| C | EXTI10 
	Tx | 4 | 12| C | EXTI12 
