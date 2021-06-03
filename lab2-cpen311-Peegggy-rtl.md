* **task1 : init : submitted**
* **task1 : task1 : submitted**
* **task2 : ksa : submitted**
* **task2 : task2 : incomplete**
* **task3 : prga : submitted**
* **task3 : arc4 : incomplete**
* **task3 : task3 : incomplete**
* **task4 : crack : incomplete**
* **task5 : doublecrack : incomplete**
Submission Incomplete! One or more of your files may be missing or unable to compile in ModelSim.


One or more of your DUTs failed to compile
* DUT task2 in task2
* DUT arc4 in task3
* DUT task3 in task3
* DUT crack in task4
* DUT doublecrack in task5


### Compilation messages:
```
Modelsim compilation of task2:task2 failed due to the following:
# ** Error: task2.sv(34): Module 'init' is not defined.
```

```
Modelsim compilation of task3:arc4 failed due to the following:
# ** Error: arc4.sv(31): Module 'init' is not defined.
# ** Error: arc4.sv(39): Module 'ksa' is not defined.
```

```
Modelsim compilation of task3:task3 failed due to the following:
# ** Error: arc4.sv(31): Module 'init' is not defined.
# ** Error: arc4.sv(39): Module 'ksa' is not defined.
```

```
Modelsim compilation of task4:crack failed due to the following:
# ** Error: crack.sv(45): Module 'arc4' is not defined.
```

```
Modelsim compilation of task5:doublecrack failed due to the following:
# ** Error: crack.sv(14): Module 'arc4' is not defined.
# ** Error: crack.sv(14): Module 'arc4' is not defined.
```

