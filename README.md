# resymbol
Rename a symbol in static library or object file.

Here are the steps you should follow to rename a symbol in a static library.
	1. Put the original .a file in the origin folder
	2. cd to the workspace folder
	3. Run resymbol.sh [symbol name] [target name]
	4. Get the renamed library from output folder

Important:
The target name must have EXACTLY THE SAME length with the original symbol name.

Discussion:
You can put more than one library in origin folder at one time. All the files in origin folder would be renamed.
You can only rename 1 symbol at one time.
If the symbol is exported, and you have to use it in your project, you have to rename it in header files by your self. Make sure they have the same name with your target name after compile.
