# Esolang Interpretor
The language(Esolang) chosen is [brainf_ck](https://esolangs.org/wiki/brainfuck) 
## Language Specs
|Command|Description|
|-------|-----------|
|>|Move right|
|<|Move left|
|+|Increment the value of memory cell|
|-|Decrement the value of memory cell|
|.|Print the value of memory cell|
|,|Scan the value and store in memory cell|
|[|If memory cell is zero jump to "]"|
|]|jump back to "[" if memory cell is not zero|
## Tests
There are two tests
- test1 "Towers of Hanoi" taken from [link](https://github.com/fabianishere/brainfuck/blob/master/examples/hanoi.bf)
- test2 "Mandelbrot set fractal viewer" taken from [link](https://github.com/erikdubbelboer/brainfuck-jit/blob/master/mandelbrot.bf)
###### Testing in Linux Environment with GAS
1. Clone the Repo
```
$ git clone https://github.com/Azfoo/Esolang.git 
``` 
2. Move in the Repo and assemble the code to generate executable
```
$ cd Esolang
$ gcc -no-pie -o bf brainf_ck.s
```
3. Run the exucatable with test inputs
```
$ ./bf hanoi.b
$ ./bf mand.b
```